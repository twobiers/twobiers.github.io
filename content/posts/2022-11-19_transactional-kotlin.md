+++ 
draft = false
title = "The @Transactional-Kotlin Mismatch"
description = "How to make your productive environment inconsistent with a single exception"
tags = [
    "java",
    "kotlin",
    "spring-boot"
]
showTableOfContents = false
issueId = 1
+++

Recently, I've worked with a Spring Boot project written Kotlin.
It had a bug which was unexplainable to me by just looking at the code.
This project is a service within a microservice architecture that is being 
developed as part of a course (Look [here](https://www.archi-lab.io/compounds/dungeon_main.html) for details).

One of the services is the so called "Game service" which is responsible for
managing the state of the game and letting players (which are services by themselves)
join a game.
Once a player has joined a game, an asynchronous communication channel is created for the
player as we tend to develop the service landscape in an event-driven style.
The code for this process looks similar to the following (Some parts are omitted and 
simplified for brevity):
```kt
@Service
class GameService {
    @Transactional
    fun joinGame(gameId: UUID, playerId: UUID) {
        val player = playerRepository.findById(playerId).orElseThrow()
        val game = gameRepository.findById(gameId).orElseThrow()

        game.joinGame(player)
        playerQueueManager.setupPlayerQueue(playerId)

        gameRepository.save(game)
    }    
}
```
Seems fine, right? A player joins a game, the exchange is being created and afterwards 
the modified game with the joined player is saved. What could go wrong?
Well, the `setupPlayerQueue()` call can throw an exception. Let's assume it throws a 
`QueueCreationException` if something goes wrong (e.g. broker not available). 
The exception inherits from the `kotlin.Exception` type.
So what would happen if the message broker is unavailable? I guess everyone would aggree 
with me, If It would make perfectly sense If a player invoking this method other RPC would 
get an error message back and should eventually be able to join the game at a later point 
of time when the broker is available again.

![Well yes, but actually no meme](https://i.kym-cdn.com/entries/icons/original/000/028/596/dsmGaKWMeHXe9QuJtq_ys30PNfTGnMsRuHuo_MUzGCg.jpg)

The player is not able to join the game again. Why? because the `joinGame(player)` method 
will check whether the player is already participating in the game and will throw an exception if so.
You might wonder why the player would be participating in the game. I mean, we didn't 
come to invoking the `save()` method at all.
Well, if you are using a JPA EntityManager within a transaction scope, it isn't required 
invoking `save()` on a repository at all. Once the transaction scope is completed, the EntityManager
takes care of persisting any changed entity.

Okay, but why would the EntityManager even persist the changed entity? I mean, we have thrown a
exception. Shouldn't the transaction be marked for rollback? Clearly it should. RTFM!
> If no custom rollback rules are configured in this annotation, 
> __the transaction will roll back on `RuntimeException` and `Error` but not on checked exceptions__. 

Source: [Spring @Transactional Annotation](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/transaction/annotation/Transactional.html)

> By default checked exceptions do not result in the transactional interceptor 
> marking the transaction for rollback and instances of RuntimeException and its 
> subclasses do. This default behavior can be modified by specifying exceptions 
> that result in the interceptor marking the transaction for rollback and/or 
> exceptions that do not result in rollback.

Source: [Java EE @Transactional Annotation](https://docs.oracle.com/javaee/7/api/javax/transaction/Transactional.html)

Easy. Everything should be rolled back as [Kotlin doesn't have checked exceptions at all](https://kotlinlang.org/docs/exceptions.html) we're good to go.

![Futurama not sure if meme](https://i.kym-cdn.com/entries/icons/original/000/006/026/NOTSUREIF.jpg)

Let's take a closer look at the previous javadoc.

> By default checked exceptions do not result in the transactional interceptor 
> marking the transaction for rollback **and instances of RuntimeException and its**
> **subclasses do.**

And here's the cause of the problem. The Kotlin compiler "bridges" the type `kotlin.Exception` 
to `java.lang.Exception` resulting in all exceptions being effectively checked exceptions during
runtime. This design decision is quite understandable, especially when thinking about the 
interoperability between Kotlin and Java.

However, let's think about the consequences. **No thrown Exception of type `kotlin.Exception`** 
**within a method marked as `@Transactional` will result in a rollback by default**.
And there is even more to it. You wouldn't even notice the issue in your integration tests, because 
test transactions are rolled back by default. It will work fine in tests and crash in 
production. By Design. Nice!

In my opionion this is a huge mismatch and I bet that this behavior will cause more bugs like this.

So what can I do to 
1. Don't use the `kotlin.Exception` type, use `java.lang.RuntimeException` instead. 
  (I guess nobody will do that in a kotlin project)
2. Explicitly add the `kotlin.Exception` type to the `@Transactional` annotation
  (This is what I did)
```kt
@Transactional(rollbackOn = [Exception::class])
fun joinGame(gameId: UUID, playerId: UUID) {
}
```
3. Customize the spring transaction manager.

An issue tracking this on the Spring Framework can be found here: [https://github.com/spring-projects/spring-framework/issues/23473](https://github.com/spring-projects/spring-framework/issues/23473)

P.S.: Technically, I lied in this post. I've experienced the issue in another part of the code, 
but I find the join semantics and code is a better fit for explaining the context as it 
is more accessible.

# Appendix

{{< details "Here is a test case validating my statements">}}

**JavaRuntimeException.java**
```java
// JavaRuntimeException.java
public class JavaRuntimeException extends RuntimeException {
    public JavaRuntimeException() {
        super("This is a Java runtime exception");
    }
}
```

**KotlinException.kt**
```kotlin
class KotlinException : Exception("This is a Kotlin exception") {
    override val message: String
        get() = "This is a Kotlin exception"
}
```

**TransactionExceptionTest.kt**
```kotlin
@SpringBootTest
@Import(TransactionExceptionTest.TestService::class)
@Transactional
class TransactionExceptionTest {
    @Component
    class TestService {
        @Transactional
        fun throwKotlin() {
            val e = KotlinException()

            println(e.javaClass.superclass)

            throw e
        }

        @Transactional
        fun throwJava() {
            val e = JavaRuntimeException()

            println(e.javaClass.superclass)

            throw e
        }
    }

    @Autowired
    lateinit var testService: TestService

    @Autowired
    lateinit var tm: PlatformTransactionManager

    @Autowired
    lateinit var td: TransactionDefinition

    @Test
    fun testKotlinTransaction() {
        val transaction = tm.getTransaction(td)
        assert(!transaction.isRollbackOnly)

        assertThrows<Exception> {
            testService.throwKotlin()
        }

        assert(transaction.isRollbackOnly)
    }

    @Test
    fun testJavaTransaction() {
        val transaction = tm.getTransaction(td)
        assert(!transaction.isRollbackOnly)

        assertThrows<Exception> {
            testService.throwJava()
        }

        assert(transaction.isRollbackOnly)
    }
}
```

{{< /details >}}
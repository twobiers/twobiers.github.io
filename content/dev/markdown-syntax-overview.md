---
title: "Markdown Syntax Overview"
---

This page provides an overview of the Markdown syntax supported by Hugo, along with some additional features and extensions.

## Basic Syntax

Below are examples of basic Markdown syntax elements.


### Headings

# H1 Heading
## H2 Heading
### H3 Heading
#### H4 Heading
##### H5 Heading
###### H6 Heading

### Emphasis

*italic text* or _italic text_
**bold text** or __bold text__
***bold and italic*** or ___bold and italic___
~~strikethrough~~

### Lists

**Unordered Lists:**
- Item 1
- Item 2
    - Nested item
    - Another nested item

**Ordered Lists:**
1. First item
2. Second item
3. Third item

### Links

[Link text](https://example.com)
[Link with title](https://example.com "Title")

### Images

![Alt text](image.jpg)
![Alt text](image.jpg "Image title")

### Blockquotes

> This is a blockquote
> It can span multiple lines

### Code

**Inline code:**
Use `code` for inline code snippets

**Code blocks:**
```python
def hello_world():
        print("Hello, World!")
```

**Code Blocks with Highlighting:**
```go {linenos=inline hl_lines=[3,"6-8"]}
package main

import "fmt"

func main() {
    for i := 0; i < 3; i++ {
        fmt.Println("Value of i:", i)
    }
}
```

### Horizontal Rules

---
***
___

## Extended Syntax

### Tables

| Header 1 | Header 2 | Header 3 |
|----------|----------|----------|
| Cell 1   | Cell 2   | Cell 3   |
| Cell 4   | Cell 5   | Cell 6   |

### Task Lists

- [x] Completed task
- [ ] Incomplete task
- [ ] Another task

### Footnotes

Here's a sentence with a footnote[^1].

[^1]: This is the footnote content.

### Definition Lists

Term
: Definition of the term

### Automatic URL Linking

https://example.com

### Escaping Characters

\* Escaped asterisk
\_ Escaped underscore
\` Escaped backtick


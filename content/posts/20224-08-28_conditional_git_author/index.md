+++ 
draft = false
title = "Setup git with multiple authors automatically"
+++

I'm pretty sure, I'm not the only one working in multiple git contexts with multiple authors. 
Maybe you also find yourself in situations where you need to juggle with multiple author configs, including:
- Work
- Private
- Anonymous
- and others...

I found myself multiple times already in situations where I've created a commit with my author set from work and vice versa.
After countless errors, I finally found a way to manage this issue at my scale and I'm pretty happy with the solution. 

Basically, within `~/.config/git`, I created multiple author configurations, within a file following the pattern like `author-github-noreply.inc` and the following content:
```ini
[user]
	email = 22715034+twobiers@users.noreply.github.com
	name = twobiers  
```
In my `~/.gitconfig` I'm now including this configuration using [conditional includes](https://git-scm.com/docs/git-config#_conditional_includes) depending on the current git directory, like this:
```ini
[includeIf "gitdir/i:private/**"]
    path = ~/.config/git/author-github-noreply.inc
[includeIf "gitdir/i:temp/**"]
	path = ~/.config/git/author-github-noreply.inc
[includeIf "gitdir/i:work/**"]
    path = ~/.config/git/author-work.inc
```
The benefit of this approach is, that I just need to remember to clone a repository in the correct directory to have my author configured correctly. 
It would be also feasible to use `hasconfig:remote.*.url` and include the correct author on a matching remote. Personally, I didn't found a reason yet to configure it like this and I feel that this would overcomplicate the mental model.
Using directories I can infer the author from a visible directory, while the remote url is mostly invisible. However, if you think it benefits you -- go ahead, try it out.

I can only say that I'm using that setup now for multiple years and can recommend it to you.

P.S. If you're interested, you can take a look at my [dotfiles repo](https://github.com/twobiers/dotfiles) for the exact setup and config that I'm using.

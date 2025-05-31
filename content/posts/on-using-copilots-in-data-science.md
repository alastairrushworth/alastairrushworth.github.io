+++
title = "On using code copilots in data science"
description = "Arguably an essential tool in data science development practice"
date = "2024-06-29"
[taxonomies]
tags=["data science", "ai", "copilot"]
categories=["Data Science"]
+++

I’ve lost track of how long I’ve been using [Github’s Copilot](https://github.com/features/copilot) via the [VSCode extension](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot) but it’s well over 18 months at this point. It’s been absolutely game-changing for my productivity and enjoyment of writing code, but I’m often surprised to find that other data scientists haven’t tried it (or an equivalent tool like [codium](https://www.qodo.ai/), [tabnine](https://www.tabnine.com/) and [cursor.sh](https://www.cursor.com/)). I’ve writing this to explain why I think it’s so important, and that it should be considered an essential part of a data scientist’s toolkit. If you don’t use a code copilot tool, I hope this provides a perspective on what you might be missing. If you do already, hopefully it resonates with your experiences.

## Writing code is slow

The physical act of typing is an order of magnitude slower than the time it takes to decide what you intend to write. While typing, you need to remember how to use tools correctly to execute your intent (_how does pandas `.pivot()` work again?_), probably google some syntax (💀 _Stack Overflow_) and fix bugs or mistakes (_ugh, forgot to `.reset_index`_). There’s also exploratory work and data analysis & also iterating and refactoring (`that didn’t work, let’s try something else`), docstrings, comments, editing YAML files, yada yada. To say nothing of starting a new project and firing up your favourite modules and writing a first implementation of something.

All of this is just slow, compared to the time it takes to imagine what you are going to do. Ok, I know some of you can touch type, have black-belts in vim shortcuts and retain code docs in your photographic memories. But a majority of data science development time is spent punching out pretty standard code, and happily, this is exactly the type of code that copilots are excellent at anticipating with very good suggestions.

A slight philosophical segue. I think there’s an important distinction to be made between _typing code_, which is something you do with your fingers (and your web browser), and _realising ideas with software_ which is something you mostly do with your brain. I’m not sure you can do one without the other, and the distinction isn’t totally crisp — but bear with me.

## Code is cheap, thinking is expensive

Something we don’t talk about enough is just how much of the code we write ends up being thrown away. Projects change and sometimes die, ideas evolve and so does our code. But many (many) written lines of development, debugging, and EDA code are ephemeral and never even seen by another person.

It’s a mistake to think of discarded code as waste, it’s an essential part of development. As many authors have observed, [writing is thinking](https://alistapart.com/article/writing-is-thinking/) and writing code is no different. This is most obvious to me in the case of [EDA, where we learn by coding, thinking and iterating](https://medium.com/@alastairmrushworth/exploratory-data-analysis-whats-the-point-56c73d33ec73) and much of this code doesn’t see the light of day. There’s more in the linked article, but I don’t at all think of EDA as an ‘analysis stage’ as it’s often framed, but more of process of thinking and investigation.

Anyways, finished code is a digital manifestation of an idea, and writing the code is a form of thinking that leads to that manifestation. There’s a ton of value in the thinking part — in general, more thinking should result in better ideas and finished software. Time is always a regularising factor on how much of this type of work can take place. Copilots act as an accelerant and multiplier that makes delivering better ideas easier, faster and maybe even delightful.

## So what gives?

Why the resistance the uptake of this type of tool? There’re a few reasons I’ve observed. The main one I think is that it’s simply passed a lot of people by — the last 2 years have passed in a haze of loud AI hype and chatbots. During the same period of time, code copilots have gone from being interesting, cool toys to something completely game-changing. You only need to scan some of the [comments on hackernews when Github Copilot first launched](the comments on hackernews when Github Copilot first launched) to get a sense of what a step change it was.

Another reasonable objection is the risk of wrong / hallucinated code inadvertently getting pushed and causing issues. To anyone worried about this, I suggest trying one of the major copilots out for a while, the risk is much lower than one might imagine. The workflow prevents this to an extent — copilots are more like very smart autocomplete, where you have full control over whether a code suggestion is accepted or not. It’s not at all like blindly copy-pasting large code generations from ChatGPT (though I believe this also has a place, but that’s for a another article).

Speaking from personal experience, I used to be a bit precious about my code, and definitely felt defensive about the idea of copilots when I first started playing with [tabnine](https://www.tabnine.com/) (which has been around longer than most). I’m not sure but I think this attitude is fairly common and is probably reinforced by the emphasis many companies put on squeaky clean SWE practises when hiring. The myth of the 10x engineer polyglot who can write the full stack and do deep specialist development definitely doesn’t help either. There’s probably a lot more to it than that, but I hope you know what I’m talking about. I think all of these cultural threads add up to a kind of jealousness over our hard-won skills that results in a reflexive rejection of tools that might displace them. I sometimes need to remind myself that over sufficiently long time scales, much of our knowledge of syntax will be made redundant anyways — in 10 years time, I expect that half of the modules I routinely use now will have changed or been updated beyond recognition. Bottom line is that it’s good to care about code, but don’t let it get in the way of trying new ways to do it.

## Wrap up: give it a go
My best advice would be to try out a copilot. I really like Github’s, because it integrates seamlessly with VSCode and it really hasn’t missed a beat since I first subscribed. It’s absolutely the easiest $10 I spend each month.
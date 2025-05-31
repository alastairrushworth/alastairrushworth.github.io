+++
title = "Why finding good tech blogs is hard"
description = "A perspective on the challenges of discovering high-quality content online"
date = "2024-06-21"
[taxonomies]
tags=["rss feeds", "blaze.email", "blogs", "content discovery"]
+++

The internet is a very big place and discovering good things is still an unsolved problem. Some of the best writing lives in the fringes of the navigable internet in independent blogs that are difficult to surface unless you already know what you are looking for. I’ve spent a lot of time working on this topic, and believe it’s not obvious why the services that purport to solve this problem, don’t (and likely never will).

Firstly an important point of clarification: the title of this post is misleading, because I don’t think we should ever attempt to create sharp discrimination between ‘good’ and ‘bad’ content, or to create a service to serve up the ‘best’ content. I think of _quality_ as being a statistic that’s only defined over a _distribution_ of content (in the statistical sense of achieving some content diversity over some unseen axis). I’ll begin by expanding this point by explaining a few ways in which the content we end up reading is inevitably from a very specific type of distribution that’s far from ideal.

## On filters
> In order to read a thing on the internet, a decision was made that you should see that thing and not something else.

It’s important to recognise that wherever we find content, on social media, news sites or search engines, someone or something decided you should see it. Maybe you made the decision, because you rolled your own tool. Maybe an algorithm did it. Maybe you read something that was trending on hacker news. It’s not intrinsically a bad thing, and doesn’t always imply intent to manipulate you. The internet is simply too big for this not to be the case. But it’s crucial to realise that we never have unfettered access to all of the internet’s content, or even an unbiased sample of any subset of it, and this has consequences.

All of that might seem a bit obvious, but it feels necessary to assert before we go into detail about how these filters express themselves in different venues. What I try to do in the following sections is give an opinionated (but hopefully relatable) perspective on the experience of discovering content across a few popular services, and hopefully shed a little light on an old problem.

I think a simple way to think of the problem is of a Venn diagram showing relevance and quality as separate, but overlapping traits. Again, I don’t mean to imply that there’s an objective way of crisply measuring the quality of a single piece of content, this is just a simplified way of thinking about content in the aggregate.

<figure style="text-align: center;">
    <img src="/images/content_1.webp" alt="drawing" width="600"/>
    <figcaption>A simple way to think about the performance of content recommendation.</figcaption>
</figure>


By __relevance__ I mean the set of content that is associated with your interests. On the other side is quality — the set of content that is good or worth reading. __Quality__ is tricky to define, but it’s easy to describe what it isn’t: SEO blog posts, bland listicles, AI content farming etc. This is the bad quality stuff we’d rather avoid.

Our aim is to find as much content as possible that is both high-quality and relevant. Of course, every person will have a slightly different Venn diagram, particularly in the relevance set, but I think it’s also true that what might be quality for me, may not be for you.

I’ve also added a relevance ‘halo’ to represent the fuzzy set of content that might not be quite as relevant to your interests, but that if of sufficient quality, you’d still read. This is one of the most important parts of this diagram in my opinion, I’ve put it there to highlight a core problem in most recommendation systems: it’s implicitly assumed that personalisation is more important that all else. I think this is too simplistic — for example, if something is of good enough quality, (or important enough), then I don’t care whether it’s relevant. In other words, content is king. The breadth of each person’s halo varies, but you get the idea — we don’t always just want more of the same.

## Search engines
Let’s get the obvious out of the way. Google and Bing are the only real players, and as custodians of indexes of the entire internet, are in principle well placed to serve content from any niche. However, we know already that this doesn’t work out in practise, at all. [Google has been struggling with SEO spam in recent years](https://arstechnica.com/gadgets/2024/01/google-search-is-losing-the-fight-with-seo-spam-study-says/) and this struggle is being compounded by the [rise of AI content](https://futurism.com/ai-garbage-destroying-google-results). The bottom line is that getting relevant content from a search engine is easy, getting good quality requires a lot of patience. Moving on…

<figure style="text-align: center;">
    <img src="/images/content_2.webp" alt="drawing" width="600"/>
    <figcaption>Search engines: huge breadth, but the average quality in search results is incredibly low.</figcaption>
</figure>


## Social media
I’m not here to criticise social media, [that’s been very well covered by others](https://www.jaronlanier.com/tenarguments.html). They are excellent tools as communication devices and for communities to organise and interact. It’s unavoidable that the financial objectives of social media companies result in incentive structures and consequent behaviours that do not maximise utility and well-being for users. To be specific, there are three particular limitations on the _experienced_ user content diet.

<figure style="text-align: center;">
    <img src="/images/content_3.webp" alt="drawing" width="600"/>
    <figcaption>Social media: Highly personalised, with a sprinkling of gems, but variety and coverage are low.</figcaption>
</figure>


__Problem 1: The popular masks the niche.__ What content you do discover is likely already popular with people similar to you. Almost by definition, niche content isn’t going to be popular enough to propagate over the network, and so most of what you could discover will be missed simply because it is niche.

__Problem 2: User content is finite.__ In order for others to discover something, someone else must first share it. The internet is a very big place, and on any given social site, a lot of content that could be shared likely isn’t being shared there to begin with.

__Problem 3: Personalisation is a trap.__ Part of the joy of discovery is finding something in a new area, on a challenging topic or from vibrant new authors. Statistically, such posts might look to ‘the algorithm’ as outside of your preferences and a less good bet for recommendation. It’s obvious why this makes sense for the social media company —if they did attempt to serve greater diversity, they’d have to risk lower average satisfaction with recommended content, and a degradation in their headline engagement metrics.

## RSS readers
Curating a flow of content via RSS feeds has long been a go-to for power users. For those that don’t know, you can subscribe to [almost any blog via an RSS feed](https://en.wikipedia.org/wiki/RSS) which updates when new posts are published. Typically you’d use a client like [feedly](https://feedly.com/) to manage your feeds and read posts. This allows you to keep up to date with any number of blogs you like to read.

<figure style="text-align: center;">
    <img src="/images/content_4.webp" alt="drawing" width="600"/>
</figure>

With RSS readers, you won’t ever need to read any spam or low quality content (unless a site you subscribe to publishes some), and you can ensure everything is relevant by being selective with the feeds you choose. Sounds great, but there are a couple of big drawbacks.

__Problem 1. You have to do discovery yourself.__ Clients like Feedly really don’t help much with deciding _what_ to subscribe to. It’s fine if you just want to follow a few major news sites, you can find those quickly. Much harder if you want to cover a broad swathe of independent writers and to find new ones

__Problem 2. Your feed reader is an unwieldy firehose with lots of irrelevant content.__ A creator might have a number of topics they like to publish articles on, maybe you are only interested in only one of them. If you subscribe to lots of blogs, you quickly end up with an explosion of articles that you need to screen by scrolling through manually.

## Honourable mentions
There are some alternative search engines that tackle this problem head-on, and I’d be remiss not to mention them. [Kagi](https://help.kagi.com/kagi/company/) is a subscription search engine service that works a bit like Google but has a stronger emphasis on higher quality, small web content. I’m a Kagi subscriber and I’ve found it refreshing and often more efficient than using google. [Exa.ai](https://exa.ai/) uses embeddings to search the index. Most interesting to me personally is [marginalia.nu](https://search.marginalia.nu/) which is free and specifically focusses on non-commercial, independent content. (Self-plug alert…) I’ve been working on [blaze.email](https://blaze.email/) for over a year now, which offers a search engine and automated newsletter digests for tech content.

Each of these offer improvements over the bigger players, though I don’t believe any truly solves the quality problem (yet).

## A final thought: an analogy with food
I’m certain someone thought of this before I did, but there’s a useful analogy to be made between the information we consume online and the food we eat. It’s almost a cliche that good health comes from a _balanced and varied diet_. Something very similar applies to our information diet — we require a level of diversity in what we read — diversity interpreted in the broadest sense of variety and heterogeneity.

What this might mean practically is that an ideal feed might appear less ‘palatable’ than the type built on engagement on a social media site, including articles that are longer and more challenging. In my view, the palatability is mostly a UI problem for an enterprising content company to solve. The UIs of most social sites are extremely basic, which is something they get away with by inflaming users with content that is designed to hit the brain stem with some reptile energy. But can we imagine a site, interface or application that rewards thinking critically and consuming from a broader outlet? Yeah, of course it’s possible.

That’s not to say you shouldn’t enjoy the occasional shitpost, but consumed responsibly within a balanced and varied diet.
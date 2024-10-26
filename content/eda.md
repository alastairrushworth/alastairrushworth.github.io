+++
title = "Exploratory Data Analysis: what’s the point?"
date = 2017-09-24

[taxonomies]
categories = ["data science", "exploratory data analysis"]
+++


Exploratory data analysis or EDA is one of the most important but difficult to codify parts of the data science toolkit. True exploratory analysis is without a sharply definable objective and evades being formalised into a set of clear steps. Despite this, EDA is used in at least a few very typical ways that connect to downstream tasks like data cleaning and hypothesis generation. But perhaps most importantly, it’s an integral part of how we learn to frame our thinking as data scientists. This post attempts to offer some perspective on the less-discussed ways in which EDA develops our contextual understanding of a data analysis.

<!-- more -->

# EDA for checking, validation and cleaning

Let’s get the obvious stuff out of the way first. Where a rough analysis plan is already in place, and some data has been assembled to support the analysis, a type of EDA serves to identify potential issues that might require remedial work before progressing. This is probably the most common type of exploratory analysis and is more closely linked to the goals of data cleaning than pure analysis and insight. This a big topic and I won’t attempt an exhaustive list here, but instead will describe a few of the most common tasks.

The most common check is for the correctness of column types. Depending on the data source, different issues might arise here, but you’ll be familiar with at least some of these. Integers incorrectly encoded as strings, strings encoded as dates, unordered categories encoded as integers. Sometimes a column that should be numeric has the very occasional string entry. There are as many causes as there are issues: perhaps you didn’t specify the correct schema when you read the data; or the data are encoded in ambiguous way that results in an inappropriate type; or maybe some earlier data manipulation induced an unintended problem.

We often check the prevalence of missing values and their dependence on other important features — usually because a lot of analysis methods do not handle missing values natively. Some columns may be totally unusable if they are mostly missing. Remedies here might include dropping or transform columns, imputing missing values, or choosing an algorithm that handles missingness out of the box.

Distribution, shift and relevance: it is important to inspect the distribution of values in each column — and consider whether these look how we’d expect (where we have an expectation). Do the distributions covary, especially with time (data are almost never consistent with stationarity with respect to time). Thinking about distributional shift is crucial for making decisions around which window of data is most important or relevant for addressing a specific question. It might expose or confirm trends and temporal patterns that downstream analysis needs to be aware of.

Measuring pairwise association provides some basic insights into how columns covary and might help reveal columns that are collinear or even identical that could be removed without detriment. It might help uncover some of the overall structure in the data or indicate collections of related columns. Pairwise association measures, like Pearson correlation coefficients, are overused in this context and are limited to only providing a linear and unconditional view of pairwise association. Nevertheless, a lot of insight can be gleaned from this type of analysis if you know what to look for.

These types of techniques provide a first look at the data and answer important questions about quality, formatting and overall dependence structure. These steps can usually be carried out by the data analyst without any external support, and are generally well supported with easy-to-use code wrappers. These are absolutely essential steps and it’s possible to learn quite a lot about the data by applying them and thinking carefully about the results. But it’s very important to recognise that there is a limit to how much can be understood with this type of analysis. There’s a lot more to EDA.

# grokking the data with EDA

> When you claim to “grok” some knowledge or technique, you are asserting that you have not merely learned it in a detached instrumental way but that it has become part of you, part of your identity.
>
> [‘grok’, The Jargon File](http://www.catb.org/~esr/jargon/html/G/grok.html)

I’ve totally made up the heading, but I think it’s by far the most important role of EDA and is mostly what the rest of this post is about. There is a sort of myth of the data analyst as a robotic processor of data, who is detached and passive. The reality is completely the opposite, where better data analysis will always come from an analyst with a deep understanding of the data and the processes that generated it. EDA has a crucial role in turning a data frame from a contextless collection of bytes into a meaningful representation of a physical process, transitioning the analyst from the passive processor to an expert with deeply internalised understanding of an area. This end state is intangible and qualitative because it happens completely in your own head. Consequently, this part of the EDA will be a creative and personal journey that is supported by a continuing internal conversation that probes and revisits your understanding of the broader context.

# Building a data narrative

The data frame you have in front of you for analysis is an incomplete and encoded representation of some real world process. Part of your role as an analyst is to solve problems and generate insights that respects the story of how the data were generated. For want of a better description, let’s call this story the data narrative. Part of this narrative might be the sequencing of events that lead to each data record coming into existence, part of it might be the data’s lineage in terms of the processing, joins and wrangling required to produce the data frame you end up with. If you are already an expert in the area you are working, this narrative may already be engrained in you. The data narrative completely frames the work you do, how you interpret every insight or modeled output, and most importantly, the credibility with which you can influence your audience.

The data narrative is a complex form of metadata and is almost never part of the data frame. If you are fortunate, your organisation might keep clear and accessible documentation and data dictionaries that will be a huge first step to piecing together this narrative. However, it is often more typical that analysts are neither domain experts nor well-provided with nice documentation. In this case, the narrative is something that must be synthesised through detective work, drawing on a combination of data analysis and the experience of domain experts. This is, of course, much easier said than done.

# The role of asking questions

> Your goal during EDA is to develop an understanding of your data. The easiest way to do this is to use questions as tools to guide your investigation. When you ask a question, the question focuses your attention on a specific part of your dataset and helps you decide which graphs, models, or transformations to make.
>
> [R for Data Science](https://r4ds.had.co.nz/exploratory-data-analysis.html), Hadley Wickham (2021)

EDA can’t happen in a computational vacuum. To do this well, we need to be alternating between interrogating the data and asking ourselves if what we find is consistent with our internal understanding of the data’s narrative. _Does what I see make sense to me? Would I feel comfortable to explain it to someone else?_# 

In large organisations, you might also be speaking with a domain expert to help with this (if that person isn’t you), though they needn’t be an internal expert if the data come from outside the organisation. If you don’t yet have direct access to such a person, demand that you do — this person will supercharge your eventual analysis and will be often be the difference between success or failure of the entire project. In the beginning, take lots of time to let experts talk more broadly about the data, as they understand all of the salient dependencies, anomalies and gotchas that will save you a lot of time in the long run. Take time to use simple data analysis to carefully confirm what you’re told. The key here is not checking for correctness, but to grow your understanding of the data: it’s important to remember that it’s one thing to be told something about the data narrative, but it’s much more meaningful to use your own analysis to see it expressed in the data.

As your understanding deepens and the analysis progresses, you’ll continue to find new patterns and structure in the data. Keep revisiting your understanding of the data narrative, and check whether what you are seeing is consistent with that. As your understanding of the data narrative matures, the gaps will come into focus: consider creative ways to use the data or ask a relevant question to close the gap. The relationship between internalised data narrative and data exploration is a two-way street.

Take time to talk your findings over with another data scientist. The key here is to aim to communicate your understanding of the data narrative without getting too mired in the technical details of the data. The process of preparing a narrative that you can explain to a colleague will help to consolidate what you’ve learned and quickly expose gaps. A fresh set of eyes will nearly always raise further questions or force you to think of your data from a different perspective.

# Do we even have the right data?
An important byproduct of the process of building a better data narrative is that your understanding of what the most important or relevant questions to ask will improve. A crucial question to keep revisiting is whether the data you have is sufficient to address the most important questions. Are there additional data sources that you draw upon to enrich or improve the analysis? Are the columns you already have in your data frame defined correctly, or should they really be specified differently? It’s typical that data sets are assembled before anyone knows exactly how the data will be used and it can pay dividends to constantly revisit the question of whether the data contains everything sufficient to answer a particular question. Many problems in data science are much more easily solved by gathering the right data (or more of it) than by using fancier techniques.

# Data hygiene and data splitting
If you frequently fit predictive models, you’ll be aware of the risks of overfitting and the need to reserve partitions of the data to check that your findings truly generalise to unseen data. The same is true for the iterative types of EDA discussed in this article. The more detailed your analysis is, the higher the risk that insights gleaned in your EDA are false discoveries (aka statistical flukes). It is important that the confirmatory part of your analysis (prediction accuracy measurement or hypothesis testing) occurs on a different piece of data to your EDA.

A related problem that frequently arises in machine learning projects is where EDA is run as a preliminary step before creating training and test splits. If the result of EDA influences your model choices (it nearly always will if done properly), then you’ve potentially reduced your test set’s ability to measure true out-of-sample error. So before you do anything, create a hygienic environment for your EDA by splitting your data, so that you don’t accidentally leak information from your test set into your model.

> Creativity and the pitfalls of the data frame API
> This was the tendency of jobs to be adapted to tools, rather than adapting tools to jobs.

> [Silvan Tomkins](https://en.wikipedia.org/wiki/Silvan_Tomkins), Computer Simulation of Personality: Frontier of Psychological Theory (1963)

Almost all data analysis now begins with some form of data frame — a tabular data format with columns of mixed types, where each row is a record. In Python and R, data analysis tooling has coalesced around the data frame object, which has been a huge convenience and productivity boost for the analyst. I wouldn’t for a second debate that this hasn’t been a positive development, but there is a risk here that EDA, because of the ease and uniformity of use of the tooling, becomes an exercise in applying boilerplate code. This creates a hidden creativity trap where the analysis can become narrowed by the range of uses supported by a particular set of tools. While such tools are extremely powerful when they are genuinely supporting you to develop your understanding of the data narrative, it’s important to avoid becoming too reliant on any single tool.

My experience is that it’s good to have familiarity with tooling at multiple levels of abstraction. Extremely high level interfaces to auto-generate certain types of exploratory analysis are very handy, and big time savers when they provide just what you need. However, the majority of EDA is more creative in nature and becoming expert with data manipulation tools like dplyr and pandas in combination with graphical tools like matplotlib and ggplot2 provides much finer control and fewer restrictions on your creativity.

The main point here is that exploratory data analysis can’t and shouldn’t be automated, because it is a process to support a human (you) to learn, and to do that well, there are few shortcuts.

# Closing thought: an analogy with critical reading and literary analysis
Like all good blog posts, my thinking on EDA began on Twitter. In the process, [Jesse Mostipak](https://x.com/kierisi) [made a great point](https://x.com/kierisi/status/1350812374165565440?s=20) that teaching EDA effectively might share similarities [to the way students are taught to interrogate literary texts](https://guides.library.harvard.edu/sixreadinghabits). I’d never considered EDA this way, but the analogy resonated strongly with me, and much of my thinking in this post owes a lot to being sent off in this direction, 🙏 thanks Jesse! There’s a lot to unpack in the analogy, and I have no training in critical reading so I can’t speak with any authority on that subject. Nevertheless, it seems that interrogating a text has broad similar to EDA in the sense of being driven by the goal of developing a deep understanding of a text.

[This article by the Farnham Street blog](https://fs.blog/how-to-read-a-book/) summarises four levels of critical reading, originally proposed by Mortimer Adler. The final most analytical form of interrogation, called synotopical or comparative reading, hits on some of the themes I’ve discussed already:

> This task is undertaken by identifying relevant passages, translating the terminology, framing and ordering the questions that need answering, defining the issues, and having a conversation with the responses.
> 
> The goal is not to achieve an overall understanding of any particular book, but rather to understand the subject and develop a deep fluency.
> 
> This is all about identifying and filling in your knowledge gaps.
>
> Farnham Street blog, [How to Read a Book: The Ultimate Guide by Mortimer Adler](https://fs.blog/how-to-read-a-book/)

Sounds familiar doesn’t it? Asking questions (of yourself), contextualising and framing, closing knowledge gaps and achieving fluency are all key parts of a successful EDA. What I’m most excited about here is that we can draw on the analytical framework of an existing and well-established discipline, as scaffolding to think about how we can make improvements to the way we teach and practice EDA. Again, full credit to Jesse for this idea.
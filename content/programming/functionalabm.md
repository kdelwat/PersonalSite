---
title: Functional agent-based modelling (or, Oprah's giving away gifts!)
date: 2018-03-17 19:01:17 +1100
description: 'A design for a purely-functional agent-based modeling system in Racket '
draft: true

---
# Introduction

Recently I've been playing around with agent-based modeling (ABM). It's a simulation technique that takes a "bottom-up" approach: by defining the interactions between individual actors, the system as a whole emerges organically. While more clever people apply it to [economics](http://cress.soc.surrey.ac.uk/web/publications/books/agent-based-modelling-economics/more-information) and [biology](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3640333/), I'm interested in it from a sport simulation perspective. If we consider a sports league to be a system built from the interactions of teams, how accurately can we model it?

In experimenting with approaches so far, I've been consistently burned by the standard drawbacks of stateful programming. The biggest stumbling block is accidental mutation of agents. When an interaction occurs, and the agents are changed as a result of it, when should state be updated? Before other events occur? During? After? My code ends up a tangle of side-effects that's a nightmare to reason about.

I decided to take a step back and consider what my ideal framework for ABM would look like. From the beginning, it had to be functional. I don't need more side-effects in my life! This is what I came up with in an afternoon.

# Requirements
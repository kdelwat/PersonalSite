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

When pared down to key features, an ABM framework only needs a few things:

1. A way to represent agents and events.
2. The ability to modify agent state based on their interactions.
3. A method for determining when and where agents interact.

In my system, I also wanted to include a way for interactions to generate further events. I think it will come in handy when modeling things like finals series or trades.

# Framework

The framework revolves around _events_. An event is a set of higher-order functions which define the ruleset of the model. A model's events define _all_ its rules; there is no need for injecting parameters or other messy approaches.

When an event occurs on a set of agents, it generates _outcomes_. Model state is a function of these outcomes, which can modify agents and create further events.

The event functions look like this:

* **selector:** a function which chooses which agents will be involved in the event's interaction.
* **interactor:** a function which produces on _outcome_ based on an interaction.
* **modifier:** a function which takes old agents and returns new agents with an outcome applied.
* **generator:** a function which generates new events based on outcomes.
* **reporter:** a function which is responsible for logging and reporting of simulation progress.

In Racket, the function definitions take fixed forms.

> (**selector** _agent_) → boolean?
>
>     _agent:_ agent?
>
>  
>
> \(**interactor** _agents)_ → (listof outcome?)
>
>     _agents:_ (listof agent?)
>
>  
>
> \(**modifier** _outcome agent)_ → agent?
>
>     _outcome:_ outcome?
>
>     _agent:_ agent?
>
>  
>
> \(**generator** _agents outcome events_) → (listof event?)
>
>     _agents:_ (listof agent?)
>
>     _outcome:_ outcome?
>
>     _events:_ (listof event?)
>
>  
>
> \(**reporter** _outcome report) ->_ struct?
>
>     _outcome:_ outcome?
>
>     _report:_ struct?

The model begins with an initial state: a list of agents in the system, and a list of events to apply. Each event is then applied one-by-one, returning a new state each time.

![A diagram showing each higher-order function in an event](/uploads/2018/03/17/ABM.png)
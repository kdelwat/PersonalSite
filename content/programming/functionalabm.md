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
* **interactor:** a function which produces an _outcome_ based on an interaction.
* **modifier:** a function which takes old agents and returns new agents with an outcome applied.
* **generator:** a function which generates new events based on outcomes.
* **reporter:** a function which is responsible for logging and reporting on simulation progress.

In Racket, the function definitions take fixed forms.

> (**selector** _agent_) → boolean?
>
> _agent:_ agent?
>
> \(**interactor** _agents)_ → (listof outcome?)
>
> _agents:_ (listof agent?)
>
> \(**modifier** _outcome agent)_ → agent?
>
> _outcome:_ outcome?
>
> _agent:_ agent?
>
> \(**generator** _agents outcome events_) → (listof event?)
>
> _agents:_ (listof agent?)
>
> _outcome:_ outcome?
>
> _events:_ (listof event?)
>
> \(**reporter** _outcome report) ->_ struct?
>
> _outcome:_ outcome?
>
> _report:_ struct?

The model begins with an initial state: a list of agents in the system, and a list of events to apply. Each event is then applied one-by-one, returning a new state every time.

![A diagram showing each higher-order function in an event](/uploads/2018/03/17/ABM.png)

# Implementation

The generic code that powers this system is quite short. We start off by defining some data structures.

    (struct event (selector interactor modifier generator reporter))
    (struct outcome (id) #:transparent)
    (struct agent (id) #:transparent)

While this will work as-is, it's helpful to define a contract to enforce the correct function signatures for events (which will save time debugging later).

    (provide  (contract-out [struct event ((selector (-> agent? boolean?))
                                           (interactor (-> (listof agent?) (listof outcome?)))
                                           (modifier (-> outcome? agent? agent?))
                                           (generator (-> (listof agent?) outcome? (listof event?) (listof event?)))
                                           (reporter (-> outcome? struct? struct?)))]))

With these structures defined, we can write a function which runs one step of the model. It should take the first event from the queue, apply it as in the diagram above, and return the new model state (note: I'm very new to Racket, so this code may not be idiomatic!).

    (define (step-model agents all-events report)
      (define event (first all-events))
      (define events (rest all-events))
    
      ; get all interacting agents
      (define selector (event-selector event))
      (define targets (filter selector agents))
    
      ; produce a list of outcomes for the interactions
      (define interactor (event-interactor event))
      (define outcomes (interactor targets))
    
      ; modify agent state based on outcomes
      (define modifier (event-modifier event))
      (define modify-agent-partial ((curry modify-agent) modifier outcomes)) 
      (define new-agents (map modify-agent-partial agents))
    
      ; generate new events based on outcomes
      (define generator ((curry (event-generator event)) agents))
      (define new-events (foldl generator events outcomes))
    
      ; generate a new report for each outcome
      (define new-report (foldl (event-reporter event) report outcomes))
    
      ; return the new state
      (list new-agents new-events new-report))
    
    ; take a modifier, a list of outcomes, and an agent. Apply each outcome to the
    ; agent if it is targeted (i.e. the ID matches)
    (define (modify-agent modifier outcomes agent)
      (define (apply-outcome outcome agent) 
        (cond
          [(equal? (agent-id agent) (outcome-id outcome)) (modifier outcome agent)]
          [else (identity agent)]))
    
      (foldl apply-outcome agent outcomes))

Once we can run the model in steps, it's easy enough to run it as a whole.

    (define (run-model agents events report)
      (cond
        [(empty? events) (list agents events report)]
        [else (let ([new-state (step-model agents events report)])
                (let ([agents (first new-state)]
                      [events (second new-state)]
                      [report (third new-state)])
                  (run-model agents events report)))]))

`run-model` will consume an entire list of initial events, returning the final model state.

# Where does Oprah come in?

Everything so far has been abstract, so I want to provide a concrete example of modeling an everyday system.

Oprah Winfrey is a popular TV host known for her exorbitant giveaways to audience members (perhaps she has a streak of socialism about her). Let's say her giveaway model looks like this:

1. For each audience member, flip a coin. If heads, they are selected for the giveaway.
2. Give each selected member $100.
3. Update tax return with donation amount (there has to be a benefit somewhere!)

Let's think about how we could model this using event functions.

Firstly, we need to create some data structures to encode the model.

    (struct tax-return (total-donated) #:transparent)
    (struct gift outcome (amount) #:transparent)
    (struct audience-member agent (wallet) #:transparent)

A `tax-return` is an example of a _report_, a `gift` an _outcome_, and an `audience-member` an _agent_.

Next, we need to implement a selector which chooses audience members.

    (define (select-from-audience agent)
      (equal? (random 2) 1))

An interactor should take the selected agents and generate outcomes based on them. In this case, it creates a gift outcome for each audience member chosen.

    (define (determine-gifts agents)
      (map (lambda (agent) (gift (agent-id agent) 100)) agents))

A modifier takes an outcome and a relevant agent, and returns a modified agent.

    (define (give-gift gift target)
      (audience-member (agent-id target) (+ (audience-member-wallet target) (gift-amount gift))))

For now, there are no extra events generated, so we'll leave the generator blank.

    (define (generate agents outcome events)
      (identity events))

It's very important to Oprah that she update her tax return with a reporter.

    (define (file-taxes outcome current-tax-return)
      (tax-return (+ (gift-amount outcome) (tax-return-total-donated current-tax-return))))

Finally, we can tie this all up in an event, and run the model!

    (define oprah-giveth (event select-from-audience determine-gifts give-gift generate file-taxes))
    
    (define initial-events (list oprah-giveth oprah-giveth oprah-giveth oprah-giveth))
    (define initial-agents (list (audience-member 0 0) (audience-member 1 100) (audience-member 2 -100)))
    (define initial-report (tax-return 0))
    (run-model initial-agents initial-events initial-report)
    
    ; (list (list (audience-member 0 300) (audience-member 1 200) (audience-member 2 200)) '() (tax-return 700))

Looks like all three audience members were endowed upon multiple times, and Oprah got a big fat discount on her taxes.

# Oprah returns to her roots

Oprah runs this giveaway for a while, and everyone seems really into it. Ratings are booming, her taxes have never looked better. But something keeps her up at night. Why is she donating money to everyone, even those who may already be rich? It just doesn't seem fair.

Luckily, she can fix this by changing her interactor, to only give a gift to the most deserving audience member chosen in each batch.

    (define (poorer? a b)
      (if (< (audience-member-wallet a) (audience-member-wallet b)) #t #f))
    
    (define (determine-gifts agents)
      (cond
        [(empty? agents) (list)]
        [else (let ([most-worthy (first (sort agents poorer?))])
                (list (gift (agent-id most-worthy) 100)))]))
    
    (run-model initial-agents initial-events initial-report)
    ; (list (list (audience-member 0 100) (audience-member 1 100) (audience-member 2 100)) '() (tax-return 300))

That seems fairer to her!

# Oprah goes rogue

There's one more change Oprah wants to make. Recently, she's really been getting into Marx (I suspected she had a socialist streak). She decides that she'll add a unique new feature to her show. Every giveaway, there'll be a small chance that she runs a _takeaway_, stealing $100 from the richest audience member selected!

To do this, she creates a new event. Only the interactor needs to change, since it just creates a different outcome.

    (define (determine-penalties agents)
      (cond
        [(empty? agents) (list)]
        [else (let ([least-worthy (last (sort agents poorer?))])
                (list (gift (agent-id least-worthy) -100)))]))
    
    (define oprah-taketh (event select-from-audience determine-penalties give-gift generate file-taxes))

Then, she modifies the generator for her giveaway event, to add a small chance of randomly adding a takeaway.

    (define (generate agents outcome events)
      (if (equal? (random 5) 1) (append (list oprah-taketh) events) (identity events)))

Perfect! Now those pesky rich will be taught a lesson.

# Summary

An ABM framework built on pure functions has a couple of key benefits:

* No unwanted side-effects messing with execution order
* Easier to reason about
* Allows for simple time-travel debugging (cool!)

Undoubtedly as I continue on my mission to simulate sporting events I'll expand and adapt the design!
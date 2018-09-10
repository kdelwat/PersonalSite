---
title: "Notes: Making Impossible States Impossible by Richard Feldman"
date: 2018-09-10T09:09:46+10:00
description: ""
---

*These are my notes on Richard Feldman's talk, ["Making Impossible States Impossible"](https://www.youtube.com/watch?v=IcgmSRJHu_8&list=PLglJM3BYAMPH2zuz1nbKHQyeawE4SN0Cd&index=11). Code samples are his.*

**Key idea:** Instead of writing endless tests for invalid inputs and state, or adding complex code to handle edge-cases, use type systems to make representing impossible state physically impossible.

**Case study:** CSS @-rules. The directives `@charset`, `@import`, and `@namespace` have to be in a very specific order, or else the stylesheet is invalid.

If they were represented as a list of properties, a user could include them in any order, so a naive generator which parses the list and creates CSS would create invalid output. What about sorting the list first? This adds complexity and edge cases.

The best solution is to make it impossible to declare an invalid stylesheet.

Instead of this type, which allows any number of invalid rule combinations:
```
type alias Stylesheet =
  { declarations: List Declaration }
```

Use a more detailed type description:
```
type alias Stylesheet =
  { charset : Maybe String 
  , imports : List Import
  , namespaces: List Namespace
  , declarations: List Declaration 
  }
```

The program off-loads the task of validation to the compiler, reducing the need for code to handle edge-cases. There is less need for tests, too, since a test for invalid state can't even compile.

**Case study:** Survey app.

How can we extend this to the model of an application?

Consider a survey app that takes questions and user responses. A naive model would look like:

```
type alias Model =
  { prompts : List String
  , responses : List (Maybe String)  
  }
```

But this means that impossible states are possible. The user could provide a response without a corresponding question:

```
{ prompts = []
, responses = [ Just "Yes" ]
}
```

A better alternative is the following, which means that neither prompt or response can stand alone.

```
type alias Question =
  { prompt : String
  , response : Maybe String
}

type alias Model =
  { questions: List Question }
```
When dealing with multiple lists, whose elements map to each other, consider combining them into a single list with multiple fields per element.

If we extend the survey app to allow for moving forwards and backwards through questions, we need to model it.

Consider the naive approach:
```
type alias History =
  { questions : List Question
  , current : Question
}
```

There are two ways to represent invalid state. There could be a current question when none exist, or a current question that doesn't exist in the question list.

```
{ questions = []
, current = weather
}

{ first : a
  , others : [b, c]
  , current : d
}
```

To fix both issues, use a zip list:
```
type alias History =
  { previous : List Question
  , current : Question
  , remaining : List Question
  }
```

**Case study:** API upgrades

When exposing an API, allowing the user to rely on implementation details is a bad idea. We need to make using internal state externally impossible.

Say that a survey app exposes an API like this:

```
back : History -> History
forward: History -> History
answer : String -> History -> History
init : Question -> List Question -> History
```

If a user's code uses something like `history.questions`, there will need to be a breaking change. 

To make such state impossible, use a *single-constructor union type*:

```
type History =
 History
   { previous : List Question
   , current : Question
   , remaining: List Question
 } 
```

There is no way to read the fields from this type, although it comes with the penalty that internally we need to destructure its fields before use.

Don't expose the single constructor, just the type. Then users can't destructure it, but can use it as a type signature.

Expose accessor functions for internal fields that may be useful.

```
questions : History -> List Question
```

**Case study:** Adding a status bar.

We want to add a status bar to the survey app. 

```
type alias Model =
  { status : Maybe String}
```

Then, we want to add an undo button if the status is "Question deleted", which points to the question to restore.

```
type alias Model =
  { status : Maybe String
  , questionToRestore : Maybe SurveyQuestion
  }
```
This model allows representing impossible state (pointing to a question, without a status).
 
```
{ status = Nothing
, questionToRestore = Just question}
```
Use union types to replace multiple Maybes in a model - it prevents invalid combinations of valued and valueless fields, and makes relationships explicit.

```
type Status
  = NoStatus
  | TextStatus String
  | DeletedStatus String Question
```




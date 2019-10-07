# Elm Truffle-Box

_Available on [GitHub](https://github.com/kdelwat/elm-truffle-box)._

As my job has taken me further into Ethereum development, I've grown increasingly frustrated with the quality of dApp tooling. The React-driven JavaScript frontends which seem to be the standard approach cause issues. Web3 is a well-built library, but not a well-designed one, and often brings problems to the table. Whether it be the hacky code required to inject its Ethereum provider into the page, or the fact that its documentation is inconsistently out-of-date, I became frustrated, and searched for some sort of wrapper which would make using the library more palatable.

At the same time, as my journey into functional programming continues, I came across the [Elm](http://elm-lang.org/) language. It's a joy to use: the compiler catches run-time errors before they can occur, the type system eliminates many bugs I would previously have struggled to pin down, and the state system maps well to my mental model.

So why not try Ethereum development with Elm? I found [cmditch's elm-ethereum](https://github.com/cmditch/elm-ethereum) library, and it was exactly what I was looking for. Elm's compiler forces me to think explicitly about errors: what happens if a transaction fails? If the node is unreachable? Or if MetaMask has the incorrect transaction nonce (a persistently irritating issue)? If I don't address these problems, the program doesn't even compile!

The only thing holding me back was the lack of a boilerplate for quickly getting started with an Elm dApp. So I made one: [elm-truffle-box](https://github.com/kdelwat/elm-truffle-box). It's a simple wrapper around elm-ethereum (and its documented examples) and Truffle, the contract development framework. You can use the compiled contracts from within Elm to create functional, safe dApps.

I hope to see more developers turning to these sorts of languages for blockchain development. It could end up eradicating a whole host of messy issues that the space is known for!

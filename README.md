## A more elegant specification for FRP

A talk given at [LambdaJam](lambdajam.com) 2015 (July 15--16).

*    Slides (PDF): [without builds](http://conal.net/talks/more-elegant-frp-lambdajam-2015.pdf), or [with](http://conal.net/talks/more-elegant-frp-lambdajam-2015-with-builds.pdf).
*    [Video](https://www.youtube.com/watch?v=teRC_Lf61Gw)

### Abstract

This talk serves as a bridge between my keynote talk on Functional Reactive Programming (FRP) and the workshop on Denotational Design.
I show how to replace most of FRP’s original denotation (semantic specification) by saying that the meaning function distributes over the abstract interfaces, made precise as simple (and possibly familiar) equations.
The resulting denotation is exactly equivalent to FRP’s original, less systematically defined, specification, but didn’t have to be invented specifically for FRP.
I call this pattern “denotational design with type class morphisms” and have found it to be applicable to many other library designs as well, some of which appear in the longer workshop. Following this pattern provides simple, precise, and compelling “specifications for free”, while guaranteeing that the usual algebraic laws hold and preventing abstraction leaks.

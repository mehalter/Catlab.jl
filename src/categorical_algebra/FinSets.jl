module FinSets

import ...Theories: dom, codom
export ⊔, AbstractMorph, FinSetMorph, dom, codom, func, AbstractSpan, leftob, rightob, apexob, Span, left, right, DoublePushout, AbstractCospan, Cospan, pushout


⊔(a::UnitRange, b::UnitRange) = 1:(length(a)+length(b))
⊔(a::AbstractVector{Int}, b::AbstractVector{Int}) = vcat(a,b)


"""    AbstractMorph

An abstract type for representing morphisms. The essential API for subtypes of AbstractMorph are

1. dom(m)::T
2. codom(m)::T
3. func(m)::Function

where T is the type of the objects in the category. See FinSetMorph for an example.
"""
abstract type AbstractMorph end

"""    FinSetMorph{T,F}

Morphisms in the category of Finite Sets. The objects are of type UnitRange{Int}.
func(m::FinSetMorph) is a function that takes `Int -> Int`. FinSetMorphs can be constructed
from a list of numbers. For example, `FinSetMorph([1,3,2,3])` is the morphism that takes
`1->1, 2->3, 3->2, 4->3` on domain `1:4` with codomain `1:3`. When you define a morphism from
a list of integers, the codomain is inferred from the largest element of the list. The domain
must always be the `1:l` where `l` is the length of the input list.

```(f::FinSetMorph)(g::G) where G <: AbstractGraph```

Lift a finite set morphism (list of integers) to a graph homomorphism by its action on the vertex
set. The graph `h = f(g)` is defined by taking the edges of `g` and relabeling their src and dst
according to the function of `f`.

This method computes a valid graph homomorphism by definition.
"""
struct FinSetMorph{T,F} <: AbstractMorph
    codom::T
    fun::F
end

FinSetMorph(v::AbstractVector{Int}) = FinSetMorph(1:maximum(v), v)

dom(m::FinSetMorph) = 1:length(m.fun)
codom(m::FinSetMorph) = m.codom
func(m::FinSetMorph) = i->m.fun[i]

"""    ⊔(f::FinSetMorph, g::FinSetMorph)

The union of two morphisms in a finite set.
"""
function ⊔(f::FinSetMorph, g::FinSetMorph)
    Y = codom(f) ⊔ codom(g)
    h = f.fun ⊔ g.fun
    FinSetMorph(Y, h)
end

end

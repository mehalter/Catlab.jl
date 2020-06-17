module Decorators

using ..FinSetMorph
import Base: append!, push!, deleteat!, delete!

export AbstractModel, model, Decorated, decorations, undecorate

"""    AbstractModel

a placeholder struct to dispatch on how to parse the expression tree into a model.
"""
abstract type AbstractModel end

""" model(::AbstractModel, x)
dig into the expression that describes a model and break it down into components. This allows you to construct a structured representation of the modeling problem at the expression level. Just like how ju
lia modeling frameworks build structured representations of the problems in data structures. This version builds them at the expression level.
The first argument is the type you want to construct, the second argument is the model structure that you want to analyze. For example
```
model(PetriModel, x::Petri.Model)::PetriModel
```
"""
function model(::Type{T}, x) where T<:AbstractModel
  error("NotImplemented: model(::$T, $(typeof(x)))")
end

"""    Decorated{M,T}

A decoration applied to the objects of a morphism, where M is a type of morphism and
type T is the category of the decoration
"""
struct Decorated{M}
    f::M
    d::AbstractArray{AbstractModel}
end

# Handle creating a decorated morphism with an array of a single type
Decorated(f, d::AbstractArray{T}) where T<:AbstractModel = Decorated(f, Vector{AbstractModel}(d))
# Handle creating a decorated morphism from a single decoration
Decorated(f, d::T) where T<:AbstractModel = Decorated(f, Vector{AbstractModel}([d]))

# Get the domain or codomain of a decorated morphism
dom(m::Decorated) = dom(m.f)
codom(m::Decorated) = codom(m.f)

# Get the decorations of a decorated morphism
function decorations(m::Decorated)
  return m.d
end
# Get the decorations of AbstractModel T of a decorated morphism
function decorations(m::Decorated, ::Type{T}) where T<:AbstractModel
  filter(x -> isa(x,T), decorations(m))
end

# Remove the decoration of a decorated morphism, and return the original morphism
function undecorate(m::Decorated)
  return m.f
end

# Add a decoration to a decorated morphism
function push!(m::Decorated, decoration::AbstractModel)
  push!(decorations(m), decoration)
end

# Add a collection of decorations to a decorated morphism
function append!(m::Decorated, decorations)
    append!(m.d, decorations)
end

# remove a decoration from a decorated morphism
function deleteat!(m::Decorated, i)
  deleteat!(decorations(m), i)
end

# Remove the decorations of AbstractModel T from a decorated morphism
function delete!(m::Decorated, ::Type{T}) where T<:AbstractModel
  filter!(x -> !isa(x,T), decorations(m))
end

function left(d::Decorated)
  return left(d.f)
end

function right(d::Decorated)
  return right(d.f)
end
end

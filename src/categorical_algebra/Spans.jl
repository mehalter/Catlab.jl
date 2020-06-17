module Spans

export AbstractSpan, leftob, rightob, apexob, Span, left, right, DoublePushout, AbstractCospan, Cospan, pushout


"""    AbstractSpan

an abstract type for representing spans. The essential API for subtypes of AbstractSpan are

1. left(s)::M
2. right(s)::M
3. pushout(s)::C

where M is the type of morphisms in the span, and C is the type of cospan that solves
a pushout of span s. See Span for an example.
"""
abstract type AbstractSpan end

leftob(s::AbstractSpan) = codom(left(s))

rightob(s::AbstractSpan) = codom(right(s))

function apexob(s::AbstractSpan)
    a = dom(left(s))
    b = dom(right(s))
    a == b || error("Inconsistent span")
    return a
end

"""    Span{F,G} <: AbstractSpan

a general span type where types F and G are types of morphisms in the span
"""
struct Span{F,G} <: AbstractSpan
    f::F
    g::G
end

function left(s::Span)
    return s.f
end

function right(s::Span)
    return s.g
end

"""    undecorate(s::Span{T,T}) where T <: Decorated

remove decorations of a span of decorated morphisms
"""
function undecorate(s::Span{T,T}) where T <: Decorated
    return Span(undecorate(left(s)), undecorate(right(s)))
end

struct DoublePushout{S<:AbstractSpan, T<:NTuple{3,AbstractMorph}}
    rule::S
    morphs::T
    application::S
end

# TODO DPO CONSTRUCTOR TO SOLVE UNKNOWN DOUBLEPUSHOUT OF FINSET
# take in Span `top` (l, c, r) and finset `l′ `, f: l -> l′
# Solve for c′ using dropdown
#     c′ = setdiff(l′, f(l)) ⊔ c
# Solve pushout for span of c′ ← c → r to get r′

# function pullback

# +
"""    AbstractCospan

an abstract type for representing cospans. The essential API for subtypes of AbstractCospan are

1. left(c)::M
2. right(c)::M
3. pullback(c)::S

where M is the type of morphisms in the cospan, and S is the type of span that solves the
pullback defined by c. See Cospan for an example.
"""
abstract type AbstractCospan end

leftob(c::AbstractCospan) = codom(left(c))

rightob(c::AbstractCospan) = codom(right(c))

function apexob(c::AbstractCospan)
    a = dom(left(c))
    b = dom(right(c))
    a == b || error("Inconsistent cospan")
    return a
end

"""    Cospan{F,G} <: AbstractCospan

a general cospan type where types F and G are types of morphisms in the cospan
"""
struct Cospan{F,G} <: AbstractCospan
    f::F
    g::G
end

function left(c::Cospan)
    return c.f
end

function right(c::Cospan)
    return c.g
end

"""    undecorate(s::Copan{T,T}) where T <: Decorated

remove decorations of a cospan of decorated morphisms
"""
function undecorate(c::Cospan{T,T}) where T <: Decorated
    return Cospan(undecorate(left(c)), undecorate(right(c)))
end

# TODO: This pushout gets the numbers mixed up. It is right up to permutation
# which is fine for when we want to do one pushout. But when we want to chain
# pushouts in order to do composition, "up to permutation" isn't good enough.
"""    pushout(s::Span{T,T}) where T <: FinSetMorph

treat f,g as a span and compute the pushout that is, the cospan of f=(f⊔g) and g=(a⊔b)
"""
function pushout(s::Span{T,U}) where {T <: FinSetMorph, U <: FinSetMorph}
    f_dict = Dict(a=>i for (i, a) in enumerate(left(s).fun))
    g′ = map(n->n in keys(f_dict) ? func(right(s))(f_dict[n]) : n+length(rightob(s)), leftob(s))

    g_dict = Dict(a=>i for (i, a) in enumerate(right(s).fun))
    f′ = map(n->n in keys(g_dict) ? g′[func(left(s))(g_dict[n])] : n, rightob(s))

    u = union(f′, g′)
    u_dict = Dict(a=>i for (i, a) in enumerate(u))
    f′ = FinSetMorph(1:length(u), map(n->u_dict[n], f′))
    g′ = FinSetMorph(1:length(u), map(n->u_dict[n], g′))

    return Cospan(f′, g′)
end

"""    pushout(s::Span{T, T}) where T <: Decorated

treat f,g as a decorated span and compute the pushout that is, the cospan of f=(f⊔g) and g=(a⊔b),
with the decoration of (f⊔g)(d)
"""
function pushout(s::Span{T, T}) where T <: Decorated
    cs = pushout(undecorate(s))
    decorations = map(x->x[1] ⊔ x[2], zip(left(s).d, right(s).d))
    return Decorated(cs, map((right(cs) ⊔ left(cs)), decorations))
end

end

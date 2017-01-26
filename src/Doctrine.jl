module Doctrine
export Category, dom, codom, id, compose, ∘
export MonoidalCategory, otimes, munit, ⊗

using Typeclass

@doc """ Doctrine: *category* (with no extra structure)
""" Category

@class Category Ob Mor begin
  dom(f::Mor)::Ob
  codom(f::Mor)::Ob
  id(A::Ob)::Mor
  compose(f::Mor, g::Mor)::Mor

  # Varargs
  compose(fs::Vararg{Mor}) = foldl(compose, fs)

  # Unicode syntax
  ∘(f::Mor, g::Mor) = compose(f, g)
  ∘(fs::Vararg{Mor}) = compose(fs...)
end

@doc """ Doctrine: *monoidal category*

Parent typeclass: `Category`

To avoid associators and unitors, we assume the monoidal category is *strict*.
By the coherence theorem, there is no loss of generality.
""" MonoidalCategory

@class MonoidalCategory Ob Mor begin
  otimes(A::Ob, B::Ob)::Ob
  otimes(f::Mor, g::Mor)::Mor
  munit(::Ob)::Ob

  # Varargs
  otimes(As::Vararg{Ob}) = foldl(otimes, As)
  otimes(fs::Vararg{Mor}) = foldl(otimes, fs)

  # Unicode syntax
  ⊗(A::Ob, B::Ob) = otimes(A, B)
  ⊗(f::Mor, g::Mor) = otimes(f, g)
  ⊗(As::Vararg{Ob}) = otimes(As...)
  ⊗(fs::Vararg{Mor}) = otimes(fs...)
end

end

# typed: true
# disable-fast-path: true
class Foo
  extend T::Generic
  extend T::Sig
  Self_Type_Member = type_template()
  Not_A_Self_Type = type_member()

  sig {params(arg: Self_Type_Member).returns(Self_Type_Member)}
  def self.bla(arg)
    arg
  end

  sig {params(arg: Self_Type_Member).returns(Self_Type_Member)}
                 # ^^^^^^^^^^^^^^^^ error: `type_template` type `T.class_of(Foo)::Self_Type_Member` used in an instance method definition
                                           # ^^^^^^^^^^^^^^^^ error: `type_template` type `T.class_of(Foo)::Self_Type_Member` used in an instance method definition
  def bla(arg)
    arg
  end

  sig{void}
  def invalid_let
    T.let(nil, Self_Type_Member)
             # ^^^^^^^^^^^^^^^^ error: `type_template` type `T.class_of(Foo)::Self_Type_Member` used in an instance method definition
  end

  sig{void}
  def self.invalid_let
    T.let(nil, Not_A_Self_Type)
             # ^^^^^^^^^^^^^^^ error: `type_member` type `Foo::Not_A_Self_Type` used in a singleton method definition
  end

  sig {params(arg: Not_A_Self_Type).returns(Not_A_Self_Type)}
                 # ^^^^^^^^^^^^^^^ error: `type_member` type `Foo::Not_A_Self_Type` used in a singleton method definition
                                          # ^^^^^^^^^^^^^^^ error: `type_member` type `Foo::Not_A_Self_Type` used in a singleton method definition
  def self.invalid(arg)
    arg
  end

  # Two dangling sigs that refer to the template/member variables
  sig {returns(Not_A_Self_Type)}
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ error: Unused type annotation. No method def before next annotation
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ error: Malformed `sig`. No method def following it


  sig {returns(Self_Type_Member)}
             # ^^^^^^^^^^^^^^^^ error: `type_template` type `T.class_of(Foo)::Self_Type_Member` used in an instance method definition
end

class FooChild < Foo # error: must be re-declared
  Self_Type_Member = type_template(fixed: String)
end

FooChild.bla("mda").length
FooChild.bla(1) # error: `Integer(1)` does not match `String` for argument `arg`


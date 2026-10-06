{
  title = "a union member is judged whole in both engines";
  adr = "0039, e6m9d, c2z7q";
  what = "`union-member-judged-whole`: over `{ 1, \"s\" }`, a first-position member that covers the definitions one by one and refuses them whole (`nullOr (either int str)`) is passed over for the later member, in gen's own evaluation; and a gen `either int str` mounted in nixpkgs' `lib.types.either` under nixpkgs' `lib.evalModules` is passed over the same way, as is a gen `nullOr int` holding null beside a value. Those are nixpkgs' values for the same constructions; gen refused all three. Controls: `[ 1 1 ]` still takes the gen member in both engines, and a gen `int` mounted alone refuses `\"s\"`, catchably, so its `merge.v2` keeps the pointwise check";
}

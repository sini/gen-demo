{
  title = "a refined option redeclared beside its own bare base is met";
  adr = "0039 (den-hoag-pbble)";
  what = "`refined-option-redeclared-beside-its-bare-base-is-met`: one option declared once as a `refined` type and once as that type's own bare base (gen `enum`, `int` and `submodule`, a widening gen `enum`, and a nixpkgs `enum`), in both orders, is the refinement itself (`{v:B | e} ⊓ B = {v:B | e}`): it serves every value both declarations accept and refuses each value the refinement or the base rejects, in gen's engine and in nixpkgs' wherever gen code decides; each form was refused outright before";
}

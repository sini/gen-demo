# ── C175 — a refusal value at an aspect position is refused by name (gen-aspects; den-hoag-3sk7j).
# gen-program returns its refusals as values. Two of them, the retired `escape` and `admit 42` (whose
# witness is the flat `42`), are forwarded unread into an aspect's `includes`, and the second is also
# written at a root. Each is refused catchably at the aspect position, naming its encoding, its code
# and the gen-rules door; an aspect included beside them is admitted. Before, the escape record was
# refused only by the unrelated orphan-leaf rule, and `admit 42` was admitted, its five keys merged
# into the aspect.

{
  genAspects,
  genProgram,
  genMerge,
}:

let
  cnf.keySemantics.nixos.category = "class";
  place =
    defs:
    (genMerge.evalModuleTree { } [
      { options.aspects = (genAspects.mkAspectSchema cnf).mkAspectOption { }; }
      { config.aspects = defs; }
    ]).config.aspects;
  refused = v: !(builtins.tryEval (builtins.deepSeq v true)).success;
  escaped = genProgram.escape {
    name = "tack";
    emits = [ "selvage" ];
    binds = [ "weft" ];
    suppresses = [ ];
    fn = { thimble, ... }: [ ];
  };
  admitted = genProgram.admit 42;
in
{
  c175Refused = {
    escapeInIncludes = refused (place { selvage.includes = [ escaped ]; }).selvage.includes;
    admitInIncludes = refused (place { selvage.includes = [ admitted ]; }).selvage.includes;
    admitAtRoot = refused (place { selvage = admitted; }).selvage;
  };
  c175Control =
    map (i: i.description)
      (place {
        selvage.includes = [ { description = "fringe"; } ];
      }).selvage.includes;
}

# `warm-over-a-refused-prior-equals-cold` — den-hoag-genonly-attrs-serve-past-check-khk2v. A warm evaluation over a
# prior that refuses runs through the prior's own continuation, never through its refusal: over a hearth whose
# undeclared `ember` the edit declares, and over a hearth whose `_module.check` defaults to an uncatchable `abort` the
# edit overrides, the warm evaluation is admitted warm and its `config` and `provenance` equal the cold evaluation's.
{
  asserts,
  genMerge,
  lib,
}:
let
  gt = genMerge.types;
  kindling = {
    options.kindling = genMerge.mkOption {
      type = gt.int;
      default = 1;
    };
  };
  warmEqualsCold =
    prior: edit:
    let
      w = genMerge.evalModuleTree {
        warmFrom = genMerge.evalModuleTree { } prior;
        editedModules = edit;
      } (prior ++ edit);
      c = genMerge.evalModuleTree { } (prior ++ edit);
    in
    w.warmDecision.mode == "warm"
    && builtins.toJSON w.config == builtins.toJSON c.config
    && builtins.toJSON w.provenance == builtins.toJSON c.provenance;
in
{
  construct = [ "warm-over-a-refused-prior-equals-cold" ];
  check = asserts (
    warmEqualsCold
      [
        kindling
        { kindling = 5; }
        { ember = 7; }
      ]
      [
        { options.ember = genMerge.mkOption { type = gt.int; }; }
      ]
    &&
      warmEqualsCold
        [
          kindling
          { kindling = 5; }
          { _module.check = lib.mkDefault (abort "the hearth's check"); }
        ]
        [ { _module.check = true; } ]
  );
}

# `borrowed-relation-through-define-type-keeps-its-check` — den-hoag-23u3j. A caller's nixpkgs record that borrows gen's
# own `int` relation over a narrower check of its own is still the caller's record: the published `types.defineType`
# returns it as itself, as it returns every record it did not complete, so its check stands wherever it is declared.
# The door completed it, because it read a completion from the relation alone, and published a `check` from gen's words,
# which the record states none of, so a value its own check rejects was served, declared alone and beside gen's `int`.
# Each refusal stands beside its passing twin, so a fold refusing everything cannot pass, and neither can one serving
# everything; the door's return reads as the record raw does.
{
  asserts,
  genMerge,
  lib,
}:
let
  ft = lib.types;
  inherit (genMerge.types) defineType int;
  read =
    types: v:
    (genMerge.evalModuleTree { } (
      map (type: { options.pick = genMerge.mkOption { inherit type; }; }) types ++ [ { pick = v; } ]
    )).config.pick;
  attempt = types: v: builtins.tryEval (builtins.deepSeq (read types v) (read types v));
  refused = types: v: !(attempt types v).success;
  served =
    types: v:
    (attempt types v) == {
      success = true;
      value = v;
    };
  # a picot count: an int below 12, gen's `int` relation borrowed so it redeclares beside gen's `int`
  picots = ft.mkOptionType {
    name = "int";
    check = v: builtins.isInt v && v < 12;
    inherit (ft.int) merge;
  };
  lace = picots // {
    inherit (int) typeMergeRel;
  };
  tatted = defineType lace;
in
{
  construct = [ "a-borrowed-relation-through-define-type-keeps-its-check" ];
  check = asserts (
    refused [ tatted ] 12
    && served [ tatted ] 3
    && refused [ int tatted ] 12
    && served [ int tatted ] 3
    && refused [ tatted int ] 12
    && served [ tatted int ] 3
    && lib.all (v: attempt [ tatted ] v == attempt [ lace ] v) [
      3
      12
      "s"
    ]
  );
}

# `nesting-plane-reads-no-payload` — C103, den-hoag-tn3qf (the nesting plane, under the 2026-09-25
# ruling). A functor payload is what a type offers to MERGE on, never what it carries, and the
# nesting plane now reads what a type carries from its carrying spellings alone. A nixpkgs `listOf`
# over a gen submodule that states its element only in the top-level `elemType` spelling threads as
# gen's own `listOf`, where it was refused as "a container outside … listOf …". The same container
# with its `nestedTypes` stripped offers the element in its payload alone and is refused by name
# (OQ1 arm (ii-a)), and one whose payload element differs from the one it states is refused by name
# (OQ2 arm (b)); both defaulted, reversible. `tryEval` cannot read which throw it caught, so this cell
# holds that each is CAUGHT and T5 row 119 (`ci/refusals/row119.sh`) holds each refusal's NAME, with
# the door and the option.
{
  asserts,
  genMerge,
  lib,
}:
let
  inherit (genMerge) evalModuleTree mkOption;
  gt = genMerge.types;
  t = lib.types;
  bobbin = gt.submodule {
    options.turns = mkOption {
      type = gt.int;
      default = 0;
    };
  };
  topOnly = (builtins.removeAttrs (t.listOf bobbin) [ "nestedTypes" ]) // {
    elemType = bobbin;
  };
  read =
    ty: v:
    let
      c =
        (evalModuleTree { } [
          { options.skein = mkOption { type = ty; }; }
          { config.skein = v; }
        ]).config.skein;
      r = builtins.tryEval (builtins.deepSeq c c);
    in
    if r.success then r.value else "refused";
  # gen's own container folds through the evaluation's accessor; a foreign fold does not
  threads = ty: (genMerge.mkOptionType ty).mergeDefs ? threaded;
  wound = [ { turns = 3; } ];
in
{
  construct = [ "C103" ];
  check = asserts (
    # the element stated at the top level is read: the container threads as gen's `listOf`
    read topOnly wound == wound
    && threads topOnly
    # control: the stock container, untouched, threads the same way
    && read (t.listOf bobbin) wound == wound
    && threads (t.listOf bobbin)
    # the payload alone states nothing it carries: refused catchably (named in T5 row 119)
    && read (t.listOf bobbin // { nestedTypes = { }; }) wound == "refused"
    # the two statements disagree: refused catchably (named in T5 row 119)
    && read (t.listOf t.str // { nestedTypes.elemType = bobbin; }) [ "a" ] == "refused"
    # control: a stock container over no nesting element keeps its own fold
    && read (t.listOf t.str) [ "a" ] == [ "a" ]
  );
}

# `door-addcheck-over-a-rehomed-container` — a-check-through-the-door-is-stated-where-nixpkgs-reads-it, den-hoag-qb4hj
# (G6 group D). `mkOptionType` over nixpkgs `addCheck` of a nixpkgs `either` or `nullOr` holding a gen `submodule` is
# re-homed as gen's own container, its check carried on the record. nixpkgs' `lib.evalModules` reads a v2 type's
# `merge.v2` `headError`, never its `check`, so gen-merge served the rejected value there. The check now rides in
# `headError` after the container's own, as nixpkgs' `addCheck` places it: the `either` declared alone, and the `nullOr`
# as a member of a nixpkgs `either`, whose fold moves to its next member on that `headError`. Each refusal stands
# beside its passing twin, so a fold refusing everything cannot pass, and neither can one serving everything.
{
  asserts,
  genMerge,
  lib,
}:
let
  ft = lib.types;
  read =
    type: v:
    (lib.evalModules {
      modules = [
        { options.bobbin = lib.mkOption { inherit type; }; }
        { bobbin = v; }
      ];
    }).config.bobbin;
  attempt = type: v: builtins.tryEval (builtins.deepSeq (read type v) (read type v));
  refused = type: v: !(attempt type v).success;
  served =
    type: v: want:
    (attempt type v) == {
      success = true;
      value = want;
    };
  bolt = genMerge.types.submodule {
    options.warp = genMerge.mkOption {
      type = genMerge.types.int;
      default = 0;
    };
  };
  notFive = v: !(builtins.isAttrs v) || v.warp or 0 != 5;
  door = t: genMerge.mkOptionType (ft.addCheck t notFive);
in
{
  construct = [ "a-check-through-the-door-is-stated-where-nixpkgs-reads-it" ];
  check = asserts (
    refused (door (ft.either bolt ft.str)) { warp = 5; }
    && served (door (ft.either bolt ft.str)) { warp = 2; } { warp = 2; }
    && served (door (ft.either bolt ft.str)) "sateen" "sateen"
    && refused (ft.either (door (ft.nullOr bolt)) ft.str) { warp = 5; }
    && served (ft.either (door (ft.nullOr bolt)) ft.str) { warp = 2; } { warp = 2; }
    && served (ft.either (door (ft.nullOr bolt)) ft.str) null null
  );
}

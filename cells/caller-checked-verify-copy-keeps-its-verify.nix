# `caller-checked-verify-copy-keeps-its-verify` — a-caller-checked-verify-copy-keeps-its-verify-declared-once,
# den-hoag-fzbap. A caller may lay a check (nixpkgs' `addCheck`, or `// { check }`) on a `// { verify }` copy before a
# published door completes it. Where the copy's `verify` is not one its completion vouches for and the door cannot
# return the copy as itself (its base is a door's import of a nixpkgs record, which carries no mint, or nixpkgs'
# `addCheck` replaced the `merge` of a gen record), the door re-completes it as a check rewrite, and the rewrite's
# check was published as the caller wrote it: declared once in nixpkgs' `lib.evalModules`, or below a nixpkgs container,
# no field nixpkgs reads stated the copy's own `verify`, so the value only the `verify` rejects was served. Each
# refusal stands beside its passing twin, so a fold refusing everything cannot pass, and neither can one serving
# everything. At a union the copy's member is picked as nixpkgs' `addCheck` twin picks it: beside `str` 4 is refused,
# beside a member coercing an int to its string 4 is served as `"4"`, and the overlapping union serves `4` through its
# other member.
{
  asserts,
  genMerge,
  lib,
}:
let
  ft = lib.types;
  read =
    types: v:
    (lib.evalModules {
      modules = map (type: { options.spool = lib.mkOption { inherit type; }; }) types ++ [
        { spool = v; }
      ];
    }).config.spool;
  attempt = types: v: builtins.tryEval (builtins.deepSeq (read types v) (read types v));
  refused = types: v: !(attempt types v).success;
  served =
    types: v: want:
    (attempt types v) == {
      success = true;
      value = want;
    };
  below10 = v: !(builtins.isInt v) || v < 10;
  notFive = v: v != 5;
  # the copy's own `verify`: it alone rejects 4
  notFour = v: if v == 4 then "rejected by the copy's verify" else null;
  inherit (genMerge) mkOptionType;
  inherit (genMerge.types) defineType nullOr int;
  # a verify copy of a door's import of a nixpkgs record, with a caller's `addCheck` laid over it
  copied = mkOptionType (ft.addCheck ft.int below10) // {
    verify = notFour;
  };
  spindle = defineType (ft.addCheck copied notFive);
  bobbin = mkOptionType (ft.addCheck copied notFive);
  # the same copy with the caller's check laid by `// { check }`
  quill = defineType (copied // { check = v: copied.check v && notFive v; });
  # a verify copy of a gen `nullOr`, whose `merge` nixpkgs' `addCheck` replaces
  sley = mkOptionType (ft.addCheck (nullOr int // { verify = notFour; }) notFive);
  # a union member that serves an int the copy refuses as its string, so the union's pick is in the value
  coerced = ft.coercedTo ft.int toString ft.str;
in
{
  construct = [ "a-caller-checked-verify-copy-keeps-its-verify-declared-once" ];
  check = asserts (
    refused [ spindle ] 4
    && refused [ spindle ] 5
    && refused [ spindle ] 20
    && served [ spindle ] 3 3
    && refused [ bobbin ] 4
    && served [ bobbin ] 3 3
    && refused [ quill ] 4
    && refused [ quill ] 5
    && served [ quill ] 3 3
    && refused [ sley ] 4
    && refused [ sley ] 5
    && served [ sley ] 3 3
    && refused [ (ft.listOf spindle) ] [ 4 ]
    && served [ (ft.listOf spindle) ] [ 3 ] [ 3 ]
    && served [ (ft.either spindle ft.int) ] 4 4
    && refused [ (ft.either spindle ft.str) ] 4
    && served [ (ft.either spindle coerced) ] 4 "4"
    && served [ (ft.either spindle coerced) ] 3 3
    && refused [ (ft.either sley ft.str) ] 4
    && served [ (ft.either sley coerced) ] 4 "4"
  );
}

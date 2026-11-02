# `deep-list-redeclared-beside-a-checked-twin` — den-hoag-redeclaration-beside-foreign-slope-vhcac. One option is declared
# N = 3 and 4 times: gen's `attrsOf`, and gen's `listOf`, over nixpkgs' `listOf (listOf int)`, beside a nixpkgs partner of
# the same outer container whose ELEMENT (`listOf (listOf int)`) is nixpkgs' `addCheck` rejecting `[ [ 7 ] ]`, placed raw
# and through each door (`genMerge.mkOptionType`, `genMerge.types.mkOptionType`), in the orders G…GP, PG…G, GPG… and
# GGPG. Every step after the first owes the partner's element check as a debt, and gen-merge's meet meets that element
# pair once, with the debt: `[ [ 7 ] ]` is refused and `[ [ 8 ] ]` served in every row, where nixpkgs' twin serves both
# (its later-operand rule drops the check). A step that met the element pair without the debt and then skipped the role
# meet that owed it serves `[ [ 7 ] ]` at N = 4 in G…GP and GGPG. This cell is EXERCISE for the meet's cost, not its
# oracle: the per-level coefficient is read by thunk counts in the den-hoag-vhcac-c2 build report.
{
  asserts,
  genMerge,
  lib,
}:
let
  t = lib.types;
  inner = t.listOf (t.listOf t.int);
  checked = t.addCheck inner (l: l != [ [ 7 ] ]);
  doors = {
    d1 = genMerge.mkOptionType;
    d2 = genMerge.types.mkOptionType;
    raw = x: x;
  };
  served =
    mods:
    let
      r = builtins.tryEval (
        let
          o = genMerge.evalModuleTree { } mods;
        in
        builtins.deepSeq o.config.loom o.config.loom
      );
    in
    if r.success then { value = r.value; } else null;
  # the words over G (gen) and P (the partner), N = 3 and 4
  words = [
    "GGP"
    "PGG"
    "GPG"
    "GGGP"
    "PGGG"
    "GPGG"
    "GGPG"
  ];
  outers = {
    attrsOf = {
      gen = genMerge.types.attrsOf;
      foreign = t.attrsOf;
      def = v: { k = [ [ v ] ]; };
    };
    listOf = {
      gen = genMerge.types.listOf;
      foreign = t.listOf;
      def = v: [ [ [ v ] ] ];
    };
  };
  letters = w: builtins.filter (c: builtins.isString c && c != "") (builtins.split "" w);
  read =
    o: v:
    lib.concatMap (
      w:
      map (
        door:
        served (
          map (c: {
            options.loom = genMerge.mkOption {
              type = if c == "G" then o.gen inner else doors.${door} (o.foreign checked);
            };
          }) (letters w)
          ++ [ { loom = o.def v; } ]
        )
      ) (builtins.attrNames doors)
    ) words;
  # 7 words × 3 doors
  cells = 21;
in
{
  construct = [ "redeclared-option-accepts-only-what-every-declaration-accepts" ];
  check = asserts (
    builtins.all (
      o:
      read o 7 == builtins.genList (_: null) cells
      && read o 8 == builtins.genList (_: { value = o.def 8; }) cells
    ) (builtins.attrValues outers)
  );
}

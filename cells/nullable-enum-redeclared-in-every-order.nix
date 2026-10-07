# `nullable-enum-redeclared-in-every-order` — den-hoag-kbiu2. One option is declared three times by
# nixpkgs' `nullOr (enum [ … ])`, one member each. nixpkgs joins the declarations to the nullable union
# of the members. Under the meet gen's engine owed each declaration's check whole, because it read an
# operand's parameters at the top constructor only, so it refused every member but the one all three
# admit (none). gen-merge now reads the parameters as a tree, so each declaration is owed relative to its
# own members, as a bare `enum` is: every member and `null` read as nixpkgs reads them, in all six
# orders, on both engines. The closing case: a value in no member is refused in every order on both
# engines. The control: a nixpkgs `addCheck` under the `nullOr` stays owed in gen's engine, so the
# member it rejects is refused in both orders while the members it admits are served.
{
  asserts,
  genMerge,
  lib,
}:
let
  t = lib.types;
  served =
    eval: mods:
    let
      r = builtins.tryEval (
        let
          o = eval mods;
        in
        builtins.deepSeq o.config.loom o.config.loom
      );
    in
    if r.success then { value = r.value; } else null;
  engines = {
    gen = served (genMerge.evalModuleTree { });
    ref = served (modules: lib.evalModules { inherit modules; });
  };
  declare = type: { options.loom = lib.mkOption { inherit type; }; };
  ne = v: t.nullOr (t.enum [ v ]);
  decls = [
    (ne "warp")
    (ne "weft")
    (ne "selvage")
  ];
  perms = [
    [
      0
      1
      2
    ]
    [
      0
      2
      1
    ]
    [
      1
      0
      2
    ]
    [
      1
      2
      0
    ]
    [
      2
      0
      1
    ]
    [
      2
      1
      0
    ]
  ];
  orders = ds: def: map (p: map (i: declare (builtins.elemAt ds i)) p ++ [ { loom = def; } ]) perms;
  answers = eng: def: map engines.${eng} (orders decls def);
  every =
    f:
    lib.all f [
      "gen"
      "ref"
    ];
  members = [
    "warp"
    "weft"
    "selvage"
    null
  ];
  wrapped = t.nullOr (
    t.addCheck (t.enum [
      "warp"
      "weft"
    ]) (v: v != "warp")
  );
  wrappedAt =
    def:
    map engines.gen [
      [
        (declare wrapped)
        (declare (ne "selvage"))
        { loom = def; }
      ]
      [
        (declare (ne "selvage"))
        (declare wrapped)
        { loom = def; }
      ]
    ];
in
{
  construct = [ "a-nullable-enum-redeclared-in-every-order-serves-the-nixpkgs-union" ];
  check = asserts (
    lib.all (
      def:
      answers "gen" def == answers "ref" def
      && answers "ref" def == builtins.genList (_: { value = def; }) 6
    ) members
    && every (eng: answers eng "felt" == builtins.genList (_: null) 6)
    &&
      wrappedAt "warp" == [
        null
        null
      ]
    &&
      wrappedAt "weft" == [
        { value = "weft"; }
        { value = "weft"; }
      ]
    &&
      wrappedAt "selvage" == [
        { value = "selvage"; }
        { value = "selvage"; }
      ]
  );
}

# `wrapped-enum-redeclared-in-every-order` — den-hoag-7kj5s (ADR-0034's Decision, ADR-0039's serve half
# and its correctness bound). One option `weave` is declared by a nixpkgs `addCheck` around gen
# `enum "weave" [ "sateen" "twill" ]` rejecting `sateen`, by nixpkgs `enum [ "twill" "satin" ]` and by
# gen `enum "loom" [ "satin" ]`. In gen's engine every one of the six orders serves `twill` and `satin`
# as the nixpkgs-only twin does in nixpkgs' engine, and refuses `sateen` (the wrapper rejects it) and a
# planted `bobbin` (in no declared enum). It used to refuse `twill` and `satin` by name in five orders
# of six, serving only `loom`, then nixpkgs' enum, then the wrapped one.
{
  asserts,
  genMerge,
  lib,
}:
let
  t = lib.types;
  g = genMerge.types;
  engines = {
    gen = genMerge.evalModuleTree { };
    ref = modules: lib.evalModules { inherit modules; };
  };
  read =
    eng: types: v:
    let
      r = builtins.tryEval (
        let
          o = engines.${eng} (
            map (type: { options.weave = lib.mkOption { inherit type; }; }) types ++ [ { weave = v; } ]
          );
        in
        builtins.deepSeq o.config.weave o.config.weave
      );
    in
    if r.success then r.value else null;
  notSateen = v: v != "sateen";
  mixed = [
    (t.addCheck (g.enum "weave" [
      "sateen"
      "twill"
    ]) notSateen)
    (t.enum [
      "twill"
      "satin"
    ])
    (g.enum "loom" [ "satin" ])
  ];
  twin = [
    (t.addCheck (t.enum [
      "sateen"
      "twill"
    ]) notSateen)
    (t.enum [
      "twill"
      "satin"
    ])
    (t.enum [ "satin" ])
  ];
  orders = l: [
    l
    [
      (builtins.elemAt l 0)
      (builtins.elemAt l 2)
      (builtins.elemAt l 1)
    ]
    [
      (builtins.elemAt l 1)
      (builtins.elemAt l 0)
      (builtins.elemAt l 2)
    ]
    [
      (builtins.elemAt l 1)
      (builtins.elemAt l 2)
      (builtins.elemAt l 0)
    ]
    [
      (builtins.elemAt l 2)
      (builtins.elemAt l 0)
      (builtins.elemAt l 1)
    ]
    [
      (builtins.elemAt l 2)
      (builtins.elemAt l 1)
      (builtins.elemAt l 0)
    ]
  ];
  at =
    eng: set: v:
    map (o: read eng o v) (orders set);
  none = builtins.genList (_: null) 6;
in
{
  construct = [ "wrapped-enum-redeclared-in-every-order" ];
  check = asserts (
    lib.all (v: at "gen" mixed v == at "ref" twin v) [
      "twill"
      "satin"
    ]
    # the twin serves both in every order, so the equality above is not two refusals
    && lib.all (v: !(builtins.elem null (at "ref" twin v))) [
      "twill"
      "satin"
    ]
    && at "gen" mixed "sateen" == none
    && at "gen" mixed "bobbin" == none
  );
}

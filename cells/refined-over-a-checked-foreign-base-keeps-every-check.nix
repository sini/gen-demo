# `refined-over-a-checked-foreign-base-keeps-every-check` — den-hoag-mq05m. gen-schema's `refined` over a FOREIGN base that
# nixpkgs' `addCheck` checked (`str` refusing "baseBad"), with a refinement refusing "refBad", is declared two and three
# times beside its bare base, beside a door return of the base (`genMerge.mkOptionType`, `genMerge.types.mkOptionType`),
# and beside gen's `str`, in every mixed order. gen's meet owes every declared check, so "baseBad" and "refBad" are refused
# in every row, where nixpkgs' later-operand rule drops the check of whichever declaration does not decide; "ok" is served
# beside the base and its door returns in every order, and beside gen's `str` wherever the refined type is declared last
# (keyed as nixpkgs keys it, on the functor name `str`). Each refusal stands beside its passing twin, so a fold refusing
# everything cannot pass, and neither can one serving everything.
{
  asserts,
  genMerge,
  inputs,
  lib,
}:
let
  schema = inputs.gen.lib.substrate.schema;
  t = genMerge.types;
  inherit (genMerge) mkOptionType;
  base = lib.types.addCheck lib.types.str (s: s != "baseBad");
  refinedR = schema.refined base {
    check = s: s != "refBad";
    message = "refBad is refused";
  };
  attempt =
    types: v:
    builtins.tryEval (
      let
        o = genMerge.evalModuleTree { } (
          map (type: { options.yarn = genMerge.mkOption { inherit type; }; }) types ++ [ { yarn = v; } ]
        );
      in
      builtins.deepSeq o.config.yarn o.config.yarn
    );
  served =
    types: v:
    attempt types v == {
      success = true;
      value = v;
    };
  refused = types: v: !(attempt types v).success;
  letters = w: builtins.filter (c: builtins.isString c && c != "") (builtins.split "" w);
  orders = [
    "RX"
    "XR"
    "RRX"
    "RXR"
    "XRR"
    "RXX"
    "XRX"
    "XXR"
  ];
  spell = x: w: map (c: if c == "R" then refinedR else x) (letters w);
  partners = {
    base = base;
    d1 = mkOptionType base;
    d2 = t.mkOptionType base;
    str = t.str;
  };
  lastIsR = w: builtins.elemAt (letters w) (builtins.length (letters w) - 1) == "R";
in
{
  construct = [ "refined-over-a-checked-foreign-base-keeps-every-check" ];
  check = asserts (
    builtins.all (
      pn:
      builtins.all (
        w:
        let
          ts = spell partners.${pn} w;
        in
        refused ts "baseBad" && refused ts "refBad" && (pn == "str" && !(lastIsR w) || served ts "ok")
      ) orders
    ) (builtins.attrNames partners)
  );
}

# `carried-meet-at-a-module-set-is-its-own-type` — den-hoag-k4f4g. A submodule option declared once wrapped by a nixpkgs
# `addCheck` and once bare is met at the module set: the declared type is the submodule restricted by the wrapper's check
# (carried at the module-set join). That record is a gen-merge construction, minted over its join and the records whose
# checks it carries (ADR-0034, regime by constructor), so it is the same type as itself and as a second declaration of the
# same pair, and a different type from the pair carrying another check or none. The wrapper's check is still enforced:
# `{ a = 3; }` refused, `{ a = 2; }` served, both orders.
# Red where the record is refused against itself (it carried its join's mark) or a value moves.
{
  asserts,
  genMerge,
  lib,
}:
let
  gt = genMerge.types;
  sm = gt.submodule {
    options.a = genMerge.mkOption {
      type = gt.int;
      default = 1;
    };
  };
  wrapped = lib.types.addCheck sm (v: (v.a or 1) != 3);
  other = lib.types.addCheck sm (v: (v.a or 1) != 4);
  decl =
    ts:
    (genMerge.evalModuleTree { } (map (ty: { options.o = genMerge.mkOption { type = ty; }; }) ts))
    .options.o.type;
  eq =
    a: b:
    let
      t = builtins.tryEval (builtins.deepSeq (gt.typeEq a b) (gt.typeEq a b));
    in
    if t.success then t.value else "REFUSED";
  val =
    ts: v:
    let
      t = builtins.tryEval (
        (genMerge.evalModuleTree { } (
          map (ty: { options.o = genMerge.mkOption { type = ty; }; }) ts ++ [ { config.o.a = v; } ]
        )).config.o.a
      );
    in
    if t.success then t.value else "REFUSED";
  c = decl [
    wrapped
    sm
  ];
  rows = {
    self = eq c c;
    twins = eq c (decl [
      wrapped
      sm
    ]);
    plain = eq c (decl [
      sm
      sm
    ]);
    other = eq c (decl [
      other
      sm
    ]);
    served = [
      (val [ wrapped sm ] 2)
      (val [ sm wrapped ] 2)
    ];
    refused = [
      (val [ wrapped sm ] 3)
      (val [ sm wrapped ] 3)
    ];
  };
in
{
  construct = [ "carried-meet-at-a-module-set-is-its-own-type" ];
  inherit rows;
  check = asserts (
    rows.self == true
    && rows.twins == true
    && rows.plain == false
    && rows.other != true
    &&
      rows.served == [
        2
        2
      ]
    &&
      rows.refused == [
        "REFUSED"
        "REFUSED"
      ]
  );
}

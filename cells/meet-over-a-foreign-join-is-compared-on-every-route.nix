# `meet-over-a-foreign-join-is-compared-on-every-route` — den-hoag-k4f4g arm (c). An option declared twice with nixpkgs'
# own types, once wrapped by a nixpkgs `addCheck`, is met over a FOREIGN join, and that met record takes one regime,
# COMPARED, whichever route builds it: the leaf meet (`int`), the meet a union hides a module set in (`either str
# submodule`), and the record carried at the bare module-set join. On every route it is not minted, it is one type with
# itself and a different one from a second declaration of the same pair (a decision, no identity: ADR-0034), nixpkgs'
# `valueMeta` is served for it where both declarations admit the value, and refused where the wrapper's check rejects
# it, as its value is (ADR-0039). Red where a route mints (the twin refused), or the metadata is refused at a good value
# or served at a bad one, or a value moves.
{
  asserts,
  genMerge,
  lib,
}:
let
  gt = genMerge.types;
  np = lib.types;
  sub = np.submodule {
    key = "meet-over-a-foreign-join";
    options.a = lib.mkOption {
      type = np.int;
      default = 1;
    };
  };
  notThree = v: !(builtins.isAttrs v) || v.a != 3;
  routes = {
    leaf = {
      ts = [
        (np.addCheck np.int (v: v != 3))
        np.int
      ];
      good = 2;
      read = m: removeAttrs m [ "_internal" ];
    };
    union = {
      ts = [
        (np.addCheck (np.either np.str sub) notThree)
        (np.either np.str sub)
      ];
      good = {
        a = 2;
      };
      read = m: m.configuration.config;
    };
    carried = {
      ts = [
        (np.addCheck sub notThree)
        sub
      ];
      good = {
        a = 2;
      };
      read = m: m.configuration.config;
    };
  };
  bad = r: if builtins.isAttrs r.good then { a = 3; } else 3;
  mods = ts: v: map (ty: { options.o = lib.mkOption { type = ty; }; }) ts ++ [ { config.o = v; } ];
  ev = ts: v: genMerge.evalModuleTree { } (mods ts v);
  try =
    x:
    let
      t = builtins.tryEval (builtins.deepSeq x x);
    in
    if t.success then t.value else "REFUSED";
  # the metadata's value-bearing read: the leaf's whole metadata less its type record, a module set's configuration
  meta = r: e: try (r.read e.options.o.valueMeta);
  row =
    r:
    let
      t = (ev r.ts r.good).options.o.type;
    in
    {
      minted = t ? __mint;
      self = try (gt.typeEq t t);
      twin = try (gt.typeEq t (ev r.ts r.good).options.o.type);
      served = meta r (ev r.ts r.good) == meta r (lib.evalModules { modules = mods r.ts r.good; });
      refused = meta r (ev r.ts (bad r));
      value = try (ev r.ts r.good).config.o;
      rejected = try (ev r.ts (bad r)).config.o;
    };
  rows = builtins.mapAttrs (_: row) routes;
in
{
  construct = [ "meet-over-a-foreign-join-is-compared-on-every-route" ];
  inherit rows;
  check = asserts (
    builtins.all (
      n:
      let
        x = rows.${n};
      in
      x.minted == false
      && x.self == true
      && x.twin == false
      && x.served
      && x.refused == "REFUSED"
      && x.value == routes.${n}.good
      && x.rejected == "REFUSED"
    ) (builtins.attrNames routes)
  );
}

# `adhoc-check-in-a-stock-host` — den-hoag-spb8r (G6 group H). In gen-merge's own evaluation, a stock nixpkgs submodule's
# option typed by an ad-hoc `either // { check }` is judged as gen judges the same option at its root: over a nixpkgs
# submodule the override is refused by name (`foreign-v2-check-override` holds the root's half), and over a gen
# submodule, which may nest, it is enforced, so `{ warp = 5; }` is refused and `{ warp = 2; }` and `"sateen"` are served.
# The host's option is folded again by the `either`'s own merge, which reads no override, so a guard that skipped the
# option-level judgement would serve `{ warp = 5; }` on both. Each refusal stands beside a served twin, so a fold
# refusing everything cannot pass.
{
  asserts,
  genMerge,
  lib,
}:
let
  t = lib.types;
  notFive = v: !(builtins.isAttrs v) || v.warp or 0 != 5;
  adHoc = e: e // { check = v: e.check v && notFive v; };
  host =
    type:
    t.submodule {
      options.welt = lib.mkOption { inherit type; };
    };
  read =
    type: v:
    (genMerge.evalModuleTree { } [
      { options.gusset = genMerge.mkOption { type = host type; }; }
      { gusset.welt = v; }
    ]).config.gusset.welt;
  attempt = type: v: builtins.tryEval (builtins.deepSeq (read type v) (read type v));
  refused = type: v: !(attempt type v).success;
  served =
    type: v: want:
    (attempt type v) == {
      success = true;
      value = want;
    };
  warp = mk: int: {
    options.warp = mk {
      type = int;
      default = 0;
    };
  };
  stockBolt = t.submodule (warp lib.mkOption t.int);
  genBolt = genMerge.types.submodule (warp genMerge.mkOption genMerge.types.int);
in
{
  construct = [ "an-ad-hoc-check-in-a-stock-host-is-judged-as-at-the-root" ];
  check = asserts (
    refused (adHoc (t.either stockBolt t.str)) { warp = 5; }
    && refused (adHoc (t.either stockBolt t.str)) { warp = 2; }
    && served (t.either stockBolt t.str) { warp = 2; } { warp = 2; }
    && refused (adHoc (t.either genBolt t.str)) { warp = 5; }
    && served (adHoc (t.either genBolt t.str)) { warp = 2; } { warp = 2; }
    && served (adHoc (t.either genBolt t.str)) "sateen" "sateen"
  );
}

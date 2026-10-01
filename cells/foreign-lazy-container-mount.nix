# `foreign-lazy-container-mount` — C125, den-hoag-lazyattrsof-nested-defs-abort-o3oz5. nixpkgs' own
# `lib.evalModules` mounts gen's `lazyAttrsOf (attrsOf spool)` and `lazyAttrsOf (listOf spool)`,
# where `spool` is a gen submodule. Each spool is one root evaluation, so the foreign eval reads
# `sateen` through it, which is nixpkgs' value for the same construction over its own types.
# gen-merge used to abort uncatchably (`attribute 'defs' missing`): the lazy fold marked its
# elements for a container node that only a gen evaluation's key walk makes. The control is the
# same shape in gen-merge's own eval, which reads the container node and must still serve it.
{
  asserts,
  genMerge,
  lib,
}:
let
  T = genMerge.types;
  spool = T.submodule {
    options.spool = genMerge.mkOption {
      type = T.str;
      default = "none";
    };
  };
  mount =
    type: v:
    (lib.evalModules {
      modules = [
        { options.seam = lib.mkOption { inherit type; }; }
        { seam = v; }
      ];
    }).config.seam;
  native =
    type: v:
    (genMerge.evalModuleTree {
      modules = [
        { options.seam = genMerge.mkOption { inherit type; }; }
        { config.seam = v; }
      ];
    }).config.seam;
  attrs = T.lazyAttrsOf (T.attrsOf spool);
  list = T.lazyAttrsOf (T.listOf spool);
in
{
  construct = [ "C125" ];
  check = asserts (
    (mount attrs { bobbin.reel.spool = "sateen"; }).bobbin.reel.spool == "sateen"
    && (builtins.head (mount list { bobbin = [ { spool = "sateen"; } ]; }).bobbin).spool == "sateen"
    # control: gen's own eval reads the same shape through its container node
    && (native attrs { bobbin.reel.spool = "sateen"; }).bobbin.reel.spool == "sateen"
  );
}

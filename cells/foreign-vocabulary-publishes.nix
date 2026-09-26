# `foreign-vocabulary-publishes` — C70, den-hoag-2f4gm. gen-merge built over a leaf vocabulary it
# never saw, nixpkgs' `str`/`int`/`bool` alone, publishes a `types` namespace: `spool` typed by the
# vocabulary's own `str` reads `sateen` and refuses `1`. It used to refuse the whole namespace,
# because an allowlist entry (`attrs`, `attrsOf`, `listOf`, `option`) naming a name the vocabulary
# lacked was judged stale. The gen-types FLAKE passed where its `lib` belongs is refused catchably;
# the same library over the flake's `lib` is the control.
{
  asserts,
  inputs,
  lib,
}:
let
  h = inputs.gen.inputs;
  over =
    types:
    import "${h.gen-merge}/lib" {
      prelude = h.gen-prelude.lib;
      inherit types;
      memo = h.gen-memo.lib;
      scope = h.gen-scope.lib;
    };
  gm = over { inherit (lib.types) str int bool; };
  read =
    v:
    (gm.evalModuleTree {
      modules = [
        { options.spool = gm.mkOption { type = gm.types.str; }; }
        { spool = v; }
      ];
    }).config.spool;
in
{
  construct = [ "C70" ];
  check = asserts (
    read "sateen" == "sateen"
    && !(builtins.tryEval (read 1)).success
    && !(builtins.tryEval (over h.gen-types).types.str).success
    && (over h.gen-types.lib).types ? listOf
  );
}

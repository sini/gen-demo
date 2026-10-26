# `author-check-beside-gen-leaf` — an-author-type-reusing-gen-int-keeps-its-check, den-hoag-n4djd.
# An author type that reuses gen's `int` relation verbatim over its own check carries gen's construction witness
# (`typeMergeRel.exact`), but the leaf answer `int` carries one construction's check, its own. Declared beside gen's
# `int`, in either order, the author's check is now owed: a value it rejects is refused, and a value both checks
# admit is served at the definition. Before, the witness was read as "the answer carries this operand", the author's
# check was dropped, and the rejected value was served.
{
  asserts,
  genMerge,
  lib,
}:
let
  t = genMerge.types;
  decls =
    types:
    lib.imap0 (i: type: {
      _file = "/demo/g${toString i}.nix";
      options.port = lib.mkOption { inherit type; };
    }) types;
  gen = types: v: (genMerge.evalModuleTree { } (decls types ++ [ { port = v; } ])).config.port;
  attempt = e: builtins.tryEval (builtins.deepSeq e e);
  # the author's own check: a port below 1024 is privileged
  unprivileged =
    lib.mkOptionType {
      name = "int";
      check = v: builtins.isInt v && v >= 1024;
      merge = lib.types.int.merge;
    }
    // {
      inherit (t.int) typeMergeRel;
    };
in
{
  construct = [ "an-author-type-reusing-gen-int-keeps-its-check" ];
  check = asserts (
    !(attempt (gen [ t.int unprivileged ] 80)).success
    && !(attempt (gen [ unprivileged t.int ] 80)).success
    &&
      attempt (gen [ t.int unprivileged ] 8080) == {
        success = true;
        value = 8080;
      }
    &&
      attempt (gen [ unprivileged t.int ] 8080) == {
        success = true;
        value = 8080;
      }
  );
}

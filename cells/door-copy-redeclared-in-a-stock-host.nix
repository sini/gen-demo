# `door-copy-redeclared-in-a-stock-host` — den-hoag-dw8d3 (G1, with den-hoag-kw5bx and den-hoag-f66c6). A nixpkgs
# `addCheck` over `listOf int`, handed through `types.defineType`, is the type of a stock nixpkgs submodule's
# option, declared in two modules with the copy later. nixpkgs' redeclaration asks the copy's `typeMerge`, and its
# own rebuild dropped the `addCheck` wrapper, so the value the check rejects was served silently. The door now
# returns the record closed under its rebuilds: under nixpkgs' own `evalModules` the `bad` value is refused and the
# `ok` value is nixpkgs' own.
{
  asserts,
  genMerge,
  lib,
}:
let
  t = lib.types;
  short = v: builtins.length v < 2;
  host =
    type:
    t.submodule {
      options.welt = lib.mkOption { inherit type; };
    };
  read =
    v:
    (lib.evalModules {
      modules = [
        { options.gusset = lib.mkOption { type = host (t.listOf t.int); }; }
        {
          options.gusset = lib.mkOption {
            type = host (genMerge.types.defineType (t.addCheck (t.listOf t.int) short));
          };
        }
        { gusset.welt = v; }
      ];
    }).config.gusset;
  outcome =
    v:
    let
      r = builtins.tryEval (builtins.deepSeq (read v) (read v));
    in
    if r.success then r.value else "refused";
in
{
  construct = [ "a-door-copy-redeclared-in-a-stock-host-keeps-its-check" ];
  check = asserts (
    outcome [
      1
      2
    ] == "refused"
    && outcome [ 1 ] == { welt = [ 1 ]; }
  );
}

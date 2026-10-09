# `sibling-stating-no-module-set-threads` — nixpkgs' `coercedTo` from a leaf whose override dereferences
# its stock rebuild's `null` as a type, to a gen submodule (`shuttle`). The leaf is a sibling of the
# threaded element and states no module set, so gen-merge's walk no longer calls its `substSubModules`
# on the marker, a call nixpkgs never makes; `coercedTo`'s own rebuild passes the leaf through
# unrebuilt. The container threads and the value is nixpkgs', a module definition reading `twill` and an
# `int` coerced to `coerced`. gen-merge used to make that call, which aborted uncatchably on
# `null // { … }` (den-hoag-87nvk). The control is the same type over nixpkgs' own submodule in
# nixpkgs' engine, which reads the same two.
{
  asserts,
  genMerge,
  lib,
}:
let
  readsNull = a: a // { substSubModules = m: readsNull (a.substSubModules m); };
  holder = lib.types.coercedTo (readsNull lib.types.int) (_: {
    weft = "coerced";
  });
  weft = m: {
    options.weft = m.mkOption {
      type = m.types.str;
      default = "plain";
    };
  };
  shuttle = genMerge.types.submodule (weft genMerge);
  twin = lib.types.submodule (weft lib);
  reads =
    evalModules: m: type: v:
    (evalModules [
      { options.seam = m.mkOption { type = holder type; }; }
      { seam = v; }
    ]).config.seam.weft;
  gen = reads (genMerge.evalModuleTree { }) genMerge shuttle;
  nixpkgs = reads (modules: lib.evalModules { inherit modules; }) lib twin;
in
{
  construct = [ "a-sibling-stating-no-module-set-is-not-asked" ];
  check = asserts (
    gen { weft = "twill"; } == "twill"
    && gen 3 == "coerced"
    && nixpkgs { weft = "twill"; } == "twill"
    && nixpkgs 3 == "coerced"
  );
}

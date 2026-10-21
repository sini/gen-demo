# `evaluation-hands-its-modules-their-own-type` — den-hoag-d2o0g. A loom's module reads `moduleType`,
# the evaluation's own type nixpkgs' `internalModule` passes every module, and holds it behind a
# function, so a deep force of the held type meets no copy of itself. Read for its argument names, a
# deep force, its name, its empty value's `warp`, the same three type hops down, and, inside a
# submodule element `foo`, the empty value's `name`, which the position names. Each must equal the
# same construction over nixpkgs' `evalModules`, where gen-merge's module was refused by name
# (`module argument `moduleType' is not defined`).
#
# den-hoag-47pw5: the type's documentation evaluation (`getSubOptions`) is nixpkgs', which lists nixpkgs'
# `noCheckForDocsModule` last: a module there reads the evaluation's `getSubModules` labels (`_file`) and its
# `_module.check`, `false`. gen-merge evaluated the docs over the type's modules and its placeholder alone, so the
# labels lacked the module and the check read `true`.
{
  asserts,
  genMerge,
  lib,
}:
let
  rows =
    {
      L,
      ev,
      sub,
      emptyOf,
    }:
    let
      opt = d: L.mkOption { default = d; };
      forces = x: (builtins.tryEval (builtins.deepSeq x true)).success;
      tries =
        x:
        let
          r = builtins.tryEval (builtins.deepSeq x x);
        in
        if r.success then r.value else "refused";
      heddle =
        { moduleType, ... }:
        {
          options.held = opt (_: moduleType);
        };
      loom = [
        { options.warp = opt "w"; }
        { warp = "x"; }
        heddle
        ({ config, ... }: { options.args = opt (builtins.attrNames config._module.args); })
      ];
      held = (ev loom).config.held null;
      hop = t: (emptyOf t).held null;
      bolt = {
        options.bolt = L.mkOption {
          type = L.types.attrsOf (sub [
            heddle
            ({ name, ... }: { options.nm = opt name; })
          ]);
          default = { };
        };
        config.bolt.foo = { };
      };
      posHeld = (ev [ bolt ]).config.bolt.foo.held null;
      reader =
        { config, moduleType, ... }:
        {
          options.subModules = opt (map (m: m._file or "-") moduleType.getSubModules);
          options.check = opt config._module.check;
        };
      docsType =
        (ev [
          {
            options.docs = L.mkOption {
              type = sub [
                heddle
                reader
              ];
            };
          }
        ]).options.docs.type;
      docs = docsType.getSubOptions [ "p" ];
    in
    {
      args = tries (ev loom).config.args;
      heldForces = forces held;
      heldName = tries held.name;
      emptyWarp = tries (emptyOf held).warp;
      threeHopsWarp = tries (emptyOf (hop (hop (hop held)))).warp;
      positionedForces = forces posHeld;
      positionedName = tries (emptyOf posHeld).nm;
      docsSubModules = tries docs.subModules.default;
      docsCheck = tries docs.check.default;
    };
  gen = rows {
    L = genMerge;
    ev = genMerge.evalModuleTree { };
    sub = genMerge.types.submodule;
    emptyOf = t: t.whenEmpty.value;
  };
  ref = rows {
    L = lib;
    ev = modules: lib.evalModules { inherit modules; };
    sub = modules: lib.types.submoduleWith { inherit modules; };
    emptyOf = t: t.emptyValue.value;
  };
in
{
  construct = [ "an-evaluation-answers-its-request-surface-as-nixpkgs-does" ];
  check = asserts (
    ref == {
      args = [
        "extendModules"
        "moduleType"
      ];
      heldForces = true;
      heldName = "submodule";
      emptyWarp = "x";
      threeHopsWarp = "x";
      positionedForces = true;
      positionedName = "foo";
      docsSubModules = [
        "-"
        "<unknown-file>"
        "<unknown-file>"
        "<built-in module that disables checks for the purpose of documentation generation>"
      ];
      docsCheck = false;
    }
    && gen == ref
  );
}

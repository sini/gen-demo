# `evaluation-hands-its-modules-their-own-type` — den-hoag-d2o0g. A loom's module reads `moduleType`,
# the evaluation's own type nixpkgs' `internalModule` passes every module, and holds it behind a
# function, so a deep force of the held type meets no copy of itself. Read for its argument names, a
# deep force, its name, its empty value's `warp`, the same three type hops down, and, inside a
# submodule element `foo`, the empty value's `name`, which the position names. Each must equal the
# same construction over nixpkgs' `evalModules`, where gen-merge's module was refused by name
# (`module argument `moduleType' is not defined`).
#
# den-hoag-1k5mi: the positioned type publishes nixpkgs' module list, read as a class string per module
# (`P` the `‹name›` placeholder, `N` the position's `name`, `M` any other): the held type's own
# `getSubModules`, the `_module.args` record read through the type reused at a second position (`again`),
# and `extendModules { prefix; }`'s set. gen-merge put the position's `name` after the definitions, with no
# placeholder, and its `extendModules` rebuilt its own list.
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
      cls =
        m:
        let
          n = m._module.args.name;
        in
        if !(builtins.isAttrs m && m ? _module.args.name) then
          "M"
        else if builtins.isAttrs n && n._type or null == "override" then
          "P"
        else
          "N";
      classes = ms: builtins.concatStringsSep "" (map cls ms);
      shuttle =
        {
          options,
          moduleType,
          extendModules,
          ...
        }:
        {
          options.record = opt (map (d: d.file) options._module.args.definitionsWithLocations);
          options.again = L.mkOption {
            type = moduleType;
            default = { };
          };
          options.extended = opt (classes (extendModules { prefix = [ "elsewhere" ]; }).type.getSubModules);
        };
      reed =
        (ev [
          {
            _file = "decl.nix";
            options.reed = L.mkOption {
              type = L.types.attrsOf (sub [ shuttle ]);
              default = { };
            };
          }
          {
            _file = "cfg.nix";
            config.reed.foo = { };
          }
        ]).config.reed.foo;
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
      positionedSubModules = tries (classes posHeld.getSubModules);
      reusedRecord = tries reed.again.record;
      extendedSubModules = tries reed.extended;
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
      positionedSubModules = "PMMNM";
      reusedRecord = [
        "decl.nix"
        "decl.nix"
        "lib/modules.nix"
        "<unknown-file>"
        "<unknown-file>"
      ];
      extendedSubModules = "PMNM";
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

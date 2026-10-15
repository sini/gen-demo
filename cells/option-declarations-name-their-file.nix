# `option-declarations-name-their-file` — den-hoag-5q139, den-hoag-fhggb. A loom declared in `heddle.nix` states a
# `bolt` option once, of a `submodule` whose module has no `_file`, and a `tally` option whose type's merge returns
# the files of its definitions, with a default beside an `mkOptionDefault` from `beam.nix`. The `bolt` sub-option's
# `declarations`, read through the served type, and the `tally` value must equal the same construction over nixpkgs'
# `evalModules`, which names `heddle.nix` in both. gen-merge named `<unknown-file>` for the first and the
# `<default>` sentinel for the default's definition in the second.
{
  asserts,
  genMerge,
  lib,
}:
let
  loom = L: [
    {
      _file = "heddle.nix";
      options.bolt = L.mkOption {
        type = L.types.submodule { options.warp = L.mkOption { type = L.types.str; }; };
      };
      options.tally = L.mkOption {
        type = lib.mkOptionType {
          name = "tally";
          merge = _loc: defs: map (d: d.file) defs;
        };
        default = "d";
      };
    }
    {
      _file = "beam.nix";
      tally = L.mkOptionDefault "x";
    }
  ];
  read = ev: {
    warp = (ev.options.bolt.type.getSubOptions [ ]).warp.declarations;
    inherit (ev.config) tally;
  };
  gen = read (genMerge.evalModuleTree { } (loom genMerge));
  ref = read (lib.evalModules { modules = loom lib; });
in
{
  construct = [ "an-option-declaration-names-its-file-as-nixpkgs-does" ];
  check = asserts (
    ref == {
      warp = [ "heddle.nix" ];
      tally = [
        "heddle.nix"
        "beam.nix"
      ];
    }
    && gen == ref
  );
}

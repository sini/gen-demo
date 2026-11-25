# `an-instance-evaluated-once-keeps-its-provenance` — den-hoag-t5ndo. gen-schema `mkInstancePaired` takes
# `mkInstanceType`'s options and kind and returns `{ type; evaluate; }` from one construction (gen-merge
# `refusingSubmodulePaired`). `evaluate loc defs` is one evaluation of that construction, returned as
# `{ config; provenance; }`, so the caller keeps where each value came from without a second evaluation. Its
# `config` is the typed merge's, the same as `mkInstanceType` on the same inputs (a definition replaces the list's
# default, as in nixpkgs); its provenance names the default and each definition's file; a definition outside the
# domain is refused on either projection; and a type derived from `type` carries no evaluator. Two live definitions
# of one list append in nixpkgs' own order, in both input orders, and the provenance lists them in that order.
{
  asserts,
  genMerge,
  genSchema,
  lib,
}:
let
  T = genMerge.types;
  schema =
    (genMerge.evalModuleTree { } [
      {
        options.schema = genSchema.mkSchemaOption { };
        config.schema.weaver = {
          options.loom = genMerge.mkOption {
            type = T.str;
            default = "jacquard";
          };
          options.threads = genMerge.mkOption {
            type = T.listOf T.str;
            default = [ "warp" ];
          };
        };
      }
    ]).config.schema;
  pair = genSchema.mkInstancePaired { } schema.weaver;
  legacy = genSchema.mkInstanceType { } schema.weaver;
  loc = [
    "weavers"
    "ada"
  ];
  defs = [
    {
      file = "ada-a.nix";
      value.threads = [ "weft" ];
    }
    {
      file = "ada-b.nix";
      value.loom = "dobby";
    }
  ];
  r = pair.evaluate loc defs;
  # Two live definitions of one list option, in both orders: the append order is nixpkgs' own `lib.evalModules`
  # on the same two definitions (the independent twin), and the provenance lists the definitions in that order.
  live = [
    {
      file = "ada-a.nix";
      value.threads = [ "weft" ];
    }
    {
      file = "ada-b.nix";
      value.threads = [ "selvage" ];
    }
  ];
  twin =
    ds:
    (lib.evalModules {
      modules = [
        {
          options.threads = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ "warp" ];
          };
        }
      ]
      ++ map (d: {
        _file = d.file;
        config = d.value;
      }) ds;
    }).config.threads;
  appendOrder =
    ds:
    let
      e = pair.evaluate loc ds;
    in
    {
      paired = e.config.threads;
      typed = (pair.type.merge loc ds).threads;
      legacy = (legacy.merge loc ds).threads;
      nixpkgs = twin ds;
      files = map (d: d.file) e.provenance.threads.defs;
      priorities = map (d: d.priority) e.provenance.threads.defs;
    };
  own = c: {
    inherit (c) loom threads;
  };
  refused = e: !(builtins.tryEval (builtins.deepSeq e e)).success;
  outside = pair.evaluate loc [
    {
      file = "ada-c.nix";
      value = 5;
    }
  ];
in
{
  construct = [ "an-instance-evaluated-once-keeps-its-provenance" ];
  check = asserts (
    builtins.attrNames pair == [
      "evaluate"
      "type"
    ]
    &&
      builtins.attrNames r == [
        "config"
        "provenance"
      ]
    &&
      own r.config == {
        loom = "dobby";
        threads = [ "weft" ];
      }
    && own r.config == own (pair.type.merge loc defs)
    && own r.config == own (legacy.merge loc defs)
    &&
      map (d: d.file) r.provenance.loom.defs == [
        "<default>"
        "ada-b.nix"
      ]
    &&
      map (d: d.file) r.provenance.threads.defs == [
        "<default>"
        "ada-a.nix"
      ]
    && refused outside.config
    && refused outside.provenance
    && !(pair.type.withArgs { } ? evaluate)
    &&
      appendOrder live == {
        paired = [
          "selvage"
          "weft"
        ];
        typed = [
          "selvage"
          "weft"
        ];
        legacy = [
          "selvage"
          "weft"
        ];
        nixpkgs = [
          "selvage"
          "weft"
        ];
        files = [
          "<default>"
          "ada-b.nix"
          "ada-a.nix"
        ];
        priorities = [
          1500
          100
          100
        ];
      }
    &&
      appendOrder (lib.reverseList live) == {
        paired = [
          "weft"
          "selvage"
        ];
        typed = [
          "weft"
          "selvage"
        ];
        legacy = [
          "weft"
          "selvage"
        ];
        nixpkgs = [
          "weft"
          "selvage"
        ];
        files = [
          "<default>"
          "ada-a.nix"
          "ada-b.nix"
        ];
        priorities = [
          1500
          100
          100
        ];
      }
  );
}

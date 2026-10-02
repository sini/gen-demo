# `gen-typed-docs-phrase` — C139, den-hoag-type-description-parity-5k1l1. nixpkgs' own
# `lib.evalModules` mounts options typed by GEN-MERGE's types (`int`, `attrsOf submodule`,
# `listOf (either int str)`, `nullOr enum`, a freeform submodule) and renders their docs through
# make-options-doc's filter (`visible && !internal`). Each rendered entry is nixpkgs' for the same
# construction over `lib.types`: gen-merge used to publish a type's constructor name as its
# `description` (`attrsOf`), so the docs read gen's words. A self-referential gen type
# (`bobbin = nullOr (oneOf [ str (attrsOf bobbin) (listOf bobbin) ])`) renders a finite phrase and
# its check-failing definition is refused catchably, where nixpkgs' own twin diverges. The control
# is a definition inside its domain, which is served.
{
  asserts,
  genMerge,
  lib,
}:
let
  shapes = T: mk: {
    spool = T.int;
    looms = T.attrsOf (
      T.submodule [
        {
          options.warp = mk {
            type = T.str;
            default = "";
            description = "warp";
          };
        }
      ]
    );
    picks = T.listOf (T.either T.int T.str);
    # den-hoag-b47r5: a `oneOf` over four members, the second phrased as a clause, reads nixpkgs'
    # left fold: the clause stays parenthesised as `either`'s first operand.
    shuttle = T.oneOf [
      T.int
      (T.mkOptionType {
        name = "dent";
        description = "reed dent, counted from the left";
        descriptionClass = "nonRestrictiveClause";
      })
      T.str
      T.bool
    ];
    weave = T.nullOr (
      T.enum' [
        "twill"
        "plain"
      ]
    );
    selvedge = T.submodule [
      {
        options.width = mk {
          type = T.int;
          default = 0;
          description = "width";
        };
      }
      { freeformType = T.attrsOf T.int; }
    ];
  };
  G = genMerge.types // {
    enum' = genMerge.types.enum "weave";
  };
  N = lib.types // {
    enum' = lib.types.enum;
  };
  eval =
    sh: v:
    lib.evalModules {
      modules = [
        {
          options = builtins.mapAttrs (
            n: type:
            lib.mkOption {
              inherit type;
              description = n;
            }
          ) sh;
        }
        v
      ];
    };
  shown =
    sh:
    map (o: { inherit (o) loc name type; }) (
      builtins.filter (o: o.visible && !o.internal) (lib.optionAttrSetToDocList (eval sh { }).options)
    );
  bobbin = G.nullOr (
    G.oneOf [
      G.str
      (G.attrsOf bobbin)
      (G.listOf bobbin)
    ]
  );
  refuses = x: !(builtins.tryEval (builtins.deepSeq x null)).success;
in
{
  construct = [ "C139" ];
  check = asserts (
    shown (shapes G genMerge.mkOption) == shown (shapes N lib.mkOption)
    && builtins.isString bobbin.description
    && refuses (eval { thread = bobbin; } { thread = 5; }).config.thread
    # control: a definition inside the self-referential type's domain is served
    && (eval { thread = bobbin; } { thread.sateen = [ "x" ]; }).config.thread == { sateen = [ "x" ]; }
  );
}

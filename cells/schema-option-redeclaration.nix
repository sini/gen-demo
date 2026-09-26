# `schema-option-redeclaration` — C78, den-hoag-bfc0k. The schema option declared
# twice merges exactly when its two entry types are one construction. `mkSchemaOption` builds its
# entry type inside its submodule's module function, so even one `loom` value declared in two files
# meets two fresh `schemaKindEntry` records; they are one construction (lib/default.nix
# `constructionRelation`), so `selvage` is read through both declarations, and so it is from two
# separate `mkSchemaOption { }` calls. Two declarations differing in `strict` are two constructions and
# are refused catchably, where before either the later one decided the kind's `strict` in silence or
# (under gen-merge's same-named refusal alone) every redeclaration was refused, the twin included.
{
  asserts,
  genMerge,
  inputs,
}:
let
  schema = inputs.gen.lib.substrate.schema;
  loom = schema.mkSchemaOption { };
  kinds =
    decls:
    builtins.attrNames
      (genMerge.evalModuleTree {
        modules = map (o: { options.schema = o; }) decls ++ [ { config.schema.selvage = { }; } ];
      }).config.schema.selvage;
  decides = e: (builtins.tryEval (builtins.deepSeq e true)).success;
  # a facet whose option is typed by a check-only `mkOptionType`: the one position the
  # `keySemantics` grammar places a type record, and a cyclic one. Its back-edge sits under
  # `description`, which a bare `==` reaches before any closure in every parse order.
  facetOf =
    _:
    let
      knot = {
        loop = knot;
      };
    in
    {
      shed = {
        category = "facet";
        option = genMerge.mkOption {
          type = genMerge.types.mkOptionType {
            name = "shed";
            description = knot;
            check = builtins.isString;
          };
        };
      };
    };
  facet = facetOf 0;
in
{
  construct = [ "C78" ];
  check = asserts (
    # one value declared twice, and two calls: one construction, read through both
    builtins.elem "strict" (kinds [
      loom
      loom
    ])
    && builtins.elem "strict" (kinds [
      (schema.mkSchemaOption { })
      (schema.mkSchemaOption { })
    ])
    # two constructions: refused catchably, both orders
    && !(decides (kinds [
      (schema.mkSchemaOption { strict = true; })
      (schema.mkSchemaOption { strict = false; })
    ]))
    && !(decides (kinds [
      (schema.mkSchemaOption { strict = false; })
      (schema.mkSchemaOption { strict = true; })
    ]))
    # the same facet written in two calls is two constructions, refused catchably; one facet value
    # shared by both calls is one
    && !(decides (kinds [
      (schema.mkSchemaOption { keySemantics = facetOf 1; })
      (schema.mkSchemaOption { keySemantics = facetOf 2; })
    ]))
    && builtins.elem "strict" (kinds [
      (schema.mkSchemaOption { keySemantics = facet; })
      (schema.mkSchemaOption { keySemantics = facet; })
    ])
    # control: declared once
    && decides (kinds [ loom ])
  );
}

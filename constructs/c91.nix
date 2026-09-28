# ── C91 — A SHORTHAND KEY BESIDE `imports` ALONE READS AS CONFIG, MATCHING ITS EXPLICIT-`config` TWIN ──
# (den-hoag-1n12c, G7). gen-merge's published `moduleSyntax.structuring` is narrowed to `config`/`options`
# (den-hoag-s7826's five-marker restatement retired), so a kind declared `{ imports = [ weftModule ];
# weft = "twill"; }` no longer has `imports` alone structuring it, and `weft` is read as a shorthand
# CONFIG definition of the option `weftModule` brings in — not an unrecognised declaration key.
#
# The equality alone would be an accident of two literals agreeing, so the DISCRIMINATOR is the same
# kind built the other way in the same cell: `{ imports = [ weftModule ]; config.weft = "twill"; }`,
# an explicit-`config` declaration nothing about `moduleSyntax.structuring` ever touched. Both read
# `"twill"` off the same instance path, `looms.jacquard.weft` — the shorthand form is not a second,
# looser reading, it is the SAME reading the explicit form always had.
{ genMerge, inputs }:
let
  c91Schema = inputs.gen.lib.substrate.schema;
  c91WeftModule = {
    options.weft = genMerge.mkOption {
      type = genMerge.types.str;
      default = "plain";
    };
  };
  c91Loom =
    explicitConfig:
    c91Schema.evalSchema {
      schemaOption = c91Schema.mkSchemaOption { };
      modules = [
        {
          config.schema.loom =
            if explicitConfig then
              {
                imports = [ c91WeftModule ];
                config.weft = "twill";
              }
            else
              {
                imports = [ c91WeftModule ];
                weft = "twill";
              };
        }
      ];
    };
  c91Instance =
    schema:
    (genMerge.evalModuleTree {
      modules = [
        { options.looms = c91Schema.mkInstanceRegistry schema.loom { }; }
        { config.looms.jacquard = { }; }
      ];
    }).config.looms.jacquard;
  c91ShorthandWeft = (c91Instance (c91Loom false)).weft;
  c91TwinWeft = (c91Instance (c91Loom true)).weft;
in
{
  inherit
    c91Schema
    c91WeftModule
    c91Loom
    c91Instance
    c91ShorthandWeft
    c91TwinWeft
    ;
}

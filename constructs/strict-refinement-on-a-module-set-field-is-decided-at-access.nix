# ── A STRICT REFINEMENT ON A MODULE-SET FIELD IS DECIDED AT ACCESS ──
# A field whose type carries a module set, at any carried depth, is checked when it is read; a field
# carrying none is checked when the instance is built. Three reads over one flounce kind whose
# `frills` is a refined submodule: the knot (each flounce's `frills` imports one option per flounce of
# the registry being built) under a STRICT refinement, which composes; a strict refinement failing on
# a static `frills`, where the sibling `hem` serves and `frills` itself refuses, catchably; and a
# strict refinement failing on the flat `hem`, which refuses the instance at construction, so the
# sibling `frills` refuses too.
{ genMerge, inputs }:
let
  S = inputs.gen.lib.substrate.schema;
  M = genMerge;
  always = {
    check = _: true;
    message = "never fails";
  };
  never = {
    check = _: false;
    message = "refused";
  };
  frillsOf = flounces: {
    imports = map (f: {
      options."frill-${f.name}" = M.mkOption {
        type = M.types.str;
        default = f.hem;
      };
    }) (builtins.attrValues flounces);
  };
  plain = _: {
    options.static = M.mkOption {
      type = M.types.str;
      default = "s";
    };
  };
  read =
    {
      frills,
      frillsRefinement ? always,
      refinements ? { },
    }:
    (M.evalModuleTree { } [
      (
        { config, ... }:
        {
          options.schema = S.mkSchemaOption { };
          config.schema.flounce = {
            options.hem = M.mkOption { type = M.types.str; };
            options.frills = M.mkOption {
              type = S.refined (M.types.submodule (frills config.flounces)) [ frillsRefinement ];
              default = { };
            };
          };
        }
      )
      (
        { config, ... }:
        {
          options.flounces = S.mkInstanceRegistry { inherit refinements; } config.schema.flounce;
        }
      )
      {
        config.flounces = {
          f1.hem = "picot";
          f2.hem = "rolled";
        };
      }
    ]).config.flounces.f1;
  orRefused =
    v:
    let
      e = builtins.tryEval (builtins.deepSeq v v);
    in
    if e.success then e.value else "REFUSED";
  failingFrills = read {
    frills = plain;
    frillsRefinement = never;
  };
  failingHem = read {
    frills = plain;
    refinements.hem = [ never ];
  };
in
{
  flounceModuleSetAccess = {
    knotFrills = (read { frills = frillsOf; }).frills;
    moduleSetFailSibling = orRefused failingFrills.hem;
    moduleSetFailField = orRefused failingFrills.frills;
    flatFailSibling = orRefused failingHem.frills;
    flatFailField = orRefused failingHem.hem;
  };
}

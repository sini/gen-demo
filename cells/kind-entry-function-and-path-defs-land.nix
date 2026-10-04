# `kind-entry-function-and-path-defs-land` — C171, den-hoag-ndwvn (ADR-0025 item 1). A kind entry def
# that is a function or a path is a module, as gen-schema's default branch and nixpkgs' submodule type
# treat it, so its content lands on every aspect. Before, gen-aspects' `mkType` filtered the defs it
# imports to attrsets and dropped the others: `config.schema.aspect = { ... }: { priority = 7; }` read
# the declared default, `0`, with no message. The attrset def and the absent def are the controls.
{
  asserts,
  genAspects,
  genMerge,
}:
let
  schema = genAspects.mkAspectSchema { keySemantics.nixos.category = "class"; };
  priorityOf =
    defs:
    (genMerge.evalModuleTree {
      modules = [
        { options.schema = schema.schemaOption; }
        (schema.mkAspectModule { })
        {
          config.schema.aspect.options.priority = genMerge.mkOption {
            type = genMerge.types.int;
            default = 0;
          };
        }
      ]
      ++ map (d: { config.schema.aspect = d; }) defs
      ++ [ { config.aspects.svc = { }; } ];
    }).config.aspects.svc.priority;
in
{
  construct = [ "C171" ];
  check = asserts (
    priorityOf [ ({ ... }: { priority = 7; }) ] == 7
    && priorityOf [ ({ ... }: { config.priority = 7; }) ] == 7
    && priorityOf [ ../fixtures/kind-entry-defs/priority.nix ] == 7
    && priorityOf [ { priority = 7; } ] == 7
    && priorityOf [ ] == 0
  );
}

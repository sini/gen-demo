# `a-refused-evaluation-serves-no-definition-value` — den-hoag-genonly-attrs-serve-past-check-khk2v. A hearth whose
# `kindling` is declared and whose `ember = 7` is not, under the default check, and a freeform hearth whose own
# `_module.check` throws: each refuses its `config`, and so refuses the gen-only attributes carrying a definition
# value (`optionDefs`, `freeformConfig`, `warmDecision.uncheckedConfig`), as nixpkgs refuses `options` and `config`.
# The metadata (`provenance`, `undeclared`) is served on the refused evaluation, and each clean twin serves the same
# value leaves, equal to its own `config`.
{
  asserts,
  genMerge,
  lib,
}:
let
  gt = genMerge.types;
  refused = v: !(builtins.tryEval (builtins.deepSeq v true)).success;
  served = v: (builtins.tryEval (builtins.deepSeq v true)).success;
  kindling = {
    options.kindling = genMerge.mkOption {
      type = gt.int;
      default = 1;
    };
  };
  orphaned = genMerge.evalModuleTree { } [
    kindling
    { kindling = 5; }
    { ember = 7; }
  ];
  orphanedTwin = genMerge.evalModuleTree { } [
    kindling
    { kindling = 5; }
  ];
  freeform =
    refuse:
    genMerge.evalModuleTree { } (
      [
        (kindling // { freeformType = gt.attrsOf gt.int; })
        {
          kindling = 5;
          ember = 7;
        }
      ]
      ++ lib.optional refuse { _module.check = throw "the hearth's check"; }
    );
in
{
  construct = [ "a-refused-evaluation-serves-no-definition-value" ];
  check = asserts (
    refused orphaned.config
    && refused orphaned.optionDefs.values
    && refused orphaned.optionDefs.topDefs
    && refused orphaned.optionDefs.realized.unmatched
    && refused orphaned.warmDecision.uncheckedConfig
    && refused (freeform true).config
    && refused (freeform true).freeformConfig
    && refused (freeform true).warmDecision.uncheckedConfig
    && served orphaned.provenance
    && served orphaned.undeclared
    && orphanedTwin.warmDecision.uncheckedConfig.kindling == orphanedTwin.config.kindling
    && served orphanedTwin.optionDefs.values
    && (freeform false).freeformConfig == { ember = (freeform false).config.ember; }
  );
}

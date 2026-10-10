# `wrapped-module-provenance-file` — C34, den-hoag-sdml-file-loss-2xeet. A definition passed through
# an unattributed `{ _file; imports }` wrapper is attributed to the wrapper's file in `provenance`,
# not to gen-merge's `<unknown-file>` fallback, and the merged value is read beside it.
#
# C34 — ADR-0025 item 1 on provenance (den-hoag-sdml-file-loss-2xeet):
# content passed through an unattributed `{ _file; imports }` wrapper is
# attributed to the WRAPPER's file, not to the engine's `<unknown-file>` fallback
# (gen-merge `collectModulesFrom`). The value is read beside the file, so a
# threading that moved the merge itself could not pass on the provenance alone.
{ asserts, genMerge }:
{
  construct = [ "wrapped-module-keeps-its-importers-file" ];
  check = asserts (
    let
      r = genMerge.evalModuleTree { } [
        { options.spool = genMerge.mkOption { type = genMerge.types.str; }; }
        {
          _file = "/demo/spool.nix";
          imports = [ { config.spool = "sateen"; } ];
        }
      ];
    in
    map (d: d.file) r.provenance.spool.defs == [ "/demo/spool.nix" ] && r.config.spool == "sateen"
  );
}

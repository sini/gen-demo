# ── T2b — the incremental plane's byte-parity cell (ADR-0008) ──
{ inputs, lib }:
let
  roster = inputs.gen.lib.mkGenLibs { inherit lib; };

  t2bCtors = {
    genMerge = roster.merge;
    genSchema = roster.schema;
    genAspects = roster.aspects;
    genTypes = roster.types;
    genPrelude = roster.prelude;
  };
  # The base is a PLAIN ATTRSET, and that is load-bearing rather than stylistic.
  # `gen-merge`'s `classifyModule` rules every FUNCTION module "dirty", and a dirty base
  # contributes its whole declared surface to the remerge footprint — so a
  # `{ genMerge, ... }:` base reuses nothing, `trace.reused` is `[ ]`, and both sides of
  # the parity below come from the same full-remerge path. An attrset classifies clean
  # structurally, WITHOUT the `pureModule` trust marker, whose author-asserted purity
  # `gen-merge`'s own README says is reused stale and silently when it lies. Hence the
  # ctors are taken from the `let` rather than from the module argument.
  t2bBase = {
    options = {
      spool = t2bCtors.genMerge.mkOption {
        type = t2bCtors.genMerge.types.str;
        default = "linen";
      };
      # UNTOUCHED by `t2bEdit`, and that is the leaf the warm arm splices from the previous
      # evaluation. With `spool` alone every declared leaf is edited and there is nothing
      # left to reuse however clean the base is: the arming is the base's SOURCE CLASS
      # together with a leaf outside the edit, not the option count on its own.
      ferrule = t2bCtors.genMerge.mkOption {
        type = t2bCtors.genMerge.types.str;
        default = "chased";
      };
    };
  };
  t2bEdit = _: {
    config.spool = "sateen";
  };
  warmBase = inputs.gen.lib.compose {
    modules = [ t2bBase ];
    specialArgs = t2bCtors;
  };
  # `warmAdmits reuseKey edits` = `attrNames edits == [ reuseKey ]` (`gen-memo/lib/warmTrace.nix`)
  # fires on `modules` alone.
  warm = warmBase.override { modules = [ t2bEdit ]; };
  cold = inputs.gen.lib.compose {
    modules = [
      t2bBase
      t2bEdit
    ];
    specialArgs = t2bCtors;
  };
in
{
  inherit
    roster
    t2bCtors
    t2bBase
    t2bEdit
    warmBase
    warm
    cold
    ;
}

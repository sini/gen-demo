# `delivery-projection` — C6. The node set, the one collected class, both Rider limbs absent from
# the classes despite both being present in the aspect body, and the bobbin door under an invented
# name. gen-aspects' exported `hasClassContent` is also called directly, on both of its clauses: the
# declared-but-unset class and a fabricated empty module each read as no content.
#
# C6 — the delivery projection: the node set, the collected class, both Rider
# limbs absent from it despite both being present in the aspect body, and the bobbin
# door under an invented name.
{
  asserts,
  bobbinProjectedNodes,
  config,
  damaskClasses,
  genAspects,
  pewterClasses,
  roster,
  stitchKeySet,
}:
{
  construct = [ "C6" ];
  check = asserts (
    builtins.attrNames config.gen.composed.nodes == [
      "damask"
      "faille"
      "grosgrain"
      "pewter"
    ]
    && pewterClasses == [ "nixos" ]
    && damaskClasses == [ ]
    &&
      stitchKeySet == [
        "binding"
        "description"
        "gusset"
        "id_hash"
        "includes"
        "key"
        "meta"
        "name"
        "nixos"
        "trim"
        "welt"
      ]
    # den-hoag-sezf's TWO WITNESSES, read as VALUES rather than as key names. The key
    # set above is satisfied by a key that merged WRONGLY, so on its own it is a meter
    # that greens on the defect; these two say what the freeform keys carry.
    #
    # `binding` (Arm A) — two cross-module definitions of an undeclared freeform key
    # whose value is a list. Pre-fix the raw `{ _type = "merge"; contents = …; }`
    # marker reached this attribute verbatim; post-fix `merge.mergeDefaultOption`
    # concatenates in declaration order.
    &&
      config.gen.composed.aspects.stitch.binding == [
        "bias"
        "hem"
      ]
    # `trim` (Arm B) — two GUARD-RECORD definitions at one freeform key, merged into
    # ONE carrier holding both fragments. Pre-fix this aborted uncatchably in
    # `flatten`/`walk`; the bodies are read in order so a carrier that dropped or
    # duplicated a fragment reads red.
    &&
      map (f: f.body) config.gen.composed.aspects.stitch.trim.fragments == [
        "piping"
        "cording"
      ]
    # `trim` DISCHARGED — the fragments above are only the carrier's bodies; this reads
    # the carrier through `applyGuard` at each thimble, so a guard that cannot address
    # its own kind (the pre-3jcs4 `pred.host` spelling read `host.name`, which a thimble
    # context does not carry) answers `null` here instead of the body.
    &&
      (genAspects.mkGuardVocab { }).applyGuard {
        thimble.name = "pewter";
      } config.gen.composed.aspects.stitch.trim == "piping"
    &&
      (genAspects.mkGuardVocab { }).applyGuard {
        thimble.name = "damask";
      } config.gen.composed.aspects.stitch.trim == "cording"
    &&
      bobbinProjectedNodes == [
        "faille"
        "grosgrain"
      ]
    # den-hoag-sgut's declaration (ADR-0018 / den-hoag-g87v term 2) — the SUBSTRATE
    # predicate called DIRECTLY, not only through gen-delivery's projection. The
    # `pewterClasses`/`damaskClasses` arms above read gen-delivery's own output, which
    # is satisfied whether the fact came from the substrate or from a consumer's
    # private re-derivation of it; these name `aspects.hasClassContent` at its own
    # call site, on the two corpus values it discriminates — `nixos` carries a real
    # class body, `gusset` is the declared-but-unset class (C6 LIMB 2, the `null`).
    && roster.aspects.hasClassContent config.gen.composed.aspects.stitch.nixos
    && !(roster.aspects.hasClassContent config.gen.composed.aspects.stitch.gusset)
    # BOTH CLAUSES of the exported predicate, at a consumer. The corpus cannot supply
    # the FABRICATED EMPTY deferredModule — gen-aspects never renders one, which is
    # the whole point of the `null` above — so this arm hands the published predicate
    # that shape directly. It is the clause gen-delivery's own realization-predicate
    # cells turn on, and so the clause that has to be present in the EXPORT before
    # gen-delivery's private duplicate can be retired onto it.
    && !(roster.aspects.hasClassContent { imports = [ ]; })
  );
}

# `closed-pattern-and-functor-class-closures-are-lifted` — den-hoag-iy9qh, den-hoag-ktnnu. Four class-key
# closures over `bobbin` (two closed patterns, two functor forms) each lift to a node guarded by
# `all [ has bobbin ]` and deliver their marker at `bobbin = "spool"`, beside the open lambda control.
# Before, gen-rules' loader aborted on each, past `tryEval`: a closed pattern was handed the module
# system's arguments (`unexpected argument 'prefix'`), and a functor was read with builtin `functionArgs`.

{
  asserts,
  liftedShapes,
  liftedShapesHasBobbin,
}:

{
  construct = [ "closed-pattern-and-functor-class-closures-are-lifted" ];
  check = asserts (
    builtins.mapAttrs (_: s: s.delivered) liftedShapes == {
      closed = "closed-spool";
      closedWithPkgs = "closedWithPkgs-spool-loom";
      functor = "functor-spool-loom";
      functorBare = "functorBare-spool";
      open = "open-spool";
    }
    && builtins.all (s: s.condition == liftedShapesHasBobbin) (builtins.attrValues liftedShapes)
  );
}

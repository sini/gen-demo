# `instance-base-module-arg-reaches-a-kind` — C29, den-hoag-jyiji. A kind's modules receive a base
# module argument the CALLER supplied (`denful/den#687`). A module that forces an argument while
# DECLARING an option cannot be served from `_module.args`: reading that forces the config fixpoint
# the module is part of, and the abort is an infinite recursion naming neither the module nor the
# argument, with no `tryEval` door. So the cell asserts the CHANNEL and never the symptom — an
# oracle whose red state hangs the runner instead of failing it is not an oracle. It declares
# through `mkInstanceRegistry`, which is the idiom a consumer writes and which builds its element as
# `attrsOf (mkInstanceType …)`, so the args cross `attrsOf`'s rebuild on the way in; a submodule
# whose rebuild re-entered the args-less constructor would drop them silently and leave this green
# over a channel that reached nothing. The discriminator is the same kind with `specialArgs`
# withheld: refused, and catchably, so the stock arm is a statement about the inlet rather than
# about where `argand` happened to come from.
#
# C29 — a kind's modules receive a base module arg the CALLER supplied
# (`denful/den#687`). The stock arm's kind module forces `argand` while declaring
# an option, which is the position that recurses when the value can only come
# from `_module.args`; it resolves, and it resolves to the value handed to
# `mkInstanceRegistry` rather than to any default. The discriminator is the SAME
# kind with `specialArgs` withheld: refused, and catchably — `tryEval` returns
# `false` instead of the runner diverging. That pair is what makes this a
# statement about the channel; a single green arm would pass on a library that
# bound `argand` from anywhere at all. The ordinary option is read beside it, so
# a corpus that had broken instances wholesale could not pass this cell either.
{
  asserts,
  c29Argand,
  c29Bobbins,
  c29KindTree,
  c29KindTreeWithheld,
  c29Supplied,
  c29Withheld,
}:
{
  construct = [ "C29" ];
  check = asserts (
    c29Supplied == "gimp"
    && c29Withheld == false
    &&
      (c29Bobbins {
        specialArgs = {
          argand = c29Argand;
        };
      }).spool == "linen"
    # ★ THE SECOND ARM, on a DIFFERENT channel and in the same cell, because the two
    # together are what "a caller can supply a base module arg" means here. A kind's
    # OWN option tree is built by `mkSchemaEntryType`'s `introspect`, which a kind
    # reaches with NO INSTANCE ANYWHERE — so the instance constructor is
    # structurally not on this path, and a landing that threaded only it left this
    # arm diverging while the first arm read green. Read on the VALUE, with the
    # withheld-args control beside it, because the forcing expression is itself an
    # instrument: `_kindNames` and `attrNames <kind>.options` both read green over a
    # diverging kind and neither would have caught this.
    && c29KindTree == "gimp"
    && c29KindTreeWithheld == false
  );
}

# ── C29 — A KIND'S MODULES RECEIVE A CALLER-SUPPLIED BASE MODULE ARG (den-hoag-jyiji) ──
# `denful/den#687`: a module that forces an argument WHILE DECLARING AN OPTION cannot be
# served from `_module.args`, because reading that forces the config fixpoint the module is
# part of. The abort is an INFINITE RECURSION naming neither the module nor the argument,
# and there is no `tryEval` door — so this cell asserts the CHANNEL, never the symptom: an
# oracle whose red state hangs the runner rather than failing it is not an oracle.
#
# Declared through `mkInstanceRegistry`, which is the idiom a consumer writes, and NOT
# through `mkInstanceType` directly: the registry builds its element as
# `attrsOf (mkInstanceType …)`, so the args cross `attrsOf`'s rebuild on the way in. That
# rebuild delegates to its element's, and a submodule whose rebuild re-entered the args-less
# constructor would drop them SILENTLY — a green corpus over a channel that reached nothing.
#
# THE DISCRIMINATOR IS IN THE SAME CELL, over the SAME kind: the identical declaration with
# `specialArgs` dropped is refused, catchably, by name. Without it the stock arm is
# consistent with `argand` arriving from somewhere other than the inlet under test.
{ genMerge, inputs }:
let
  c29Schema = inputs.gen.lib.substrate.schema;
  c29Argand.selvage = "gimp";
  c29BobbinWith =
    args:
    c29Schema.evalSchema (
      {
        modules = [
          {
            config.schema.bobbin = {
              imports = [
                (
                  { argand, ... }:
                  {
                    options.selvage = genMerge.mkOption {
                      type = genMerge.types.str;
                      default = argand.selvage;
                    };
                  }
                )
              ];
              options.spool = genMerge.mkOption { type = genMerge.types.str; };
            };
          }
        ];
      }
      // args
    );
  c29Bobbin = c29BobbinWith {
    specialArgs = {
      argand = c29Argand;
    };
  };

  # ★★ THE SECOND ARM, AND IT IS A DIFFERENT CHANNEL. A kind's OWN OPTION TREE is built by
  # `mkSchemaEntryType`'s `introspect` — a direct `evalModuleTree` — which a kind reaches with
  # NO INSTANCE ANYWHERE, so the instance constructor is not on this path and cannot serve it.
  # Read on the VALUE the caller handed in, not on "it evaluated": a channel that merely
  # produced a better error message would pass the second reading and fail this one.
  #
  # ★ THE FORCING EXPRESSION IS ITSELF AN INSTRUMENT. `_kindNames` does not force a kind's
  # modules, and `attrNames <kind>.options` applies the module but not its option DEFAULTS —
  # both read green over a diverging kind. `…options.selvage.default` is the live one, and
  # `c29Withheld` is the paired control that says so.
  c29KindTree = (c29Bobbin.bobbin.options.selvage.default);
  c29KindTreeWithheld =
    (builtins.tryEval (builtins.deepSeq (c29BobbinWith { }).bobbin.options.selvage.default null))
    .success;
  c29Bobbins =
    args:
    (genMerge.evalModuleTree {
      modules = [
        { options.bobbins = c29Schema.mkInstanceRegistry c29Bobbin.bobbin args; }
        { config.bobbins.pewter.spool = "linen"; }
      ];
    }).config.bobbins.pewter;
  c29Supplied =
    (c29Bobbins {
      specialArgs = {
        argand = c29Argand;
      };
    }).selvage;
  c29Withheld = (builtins.tryEval (builtins.deepSeq (c29Bobbins { }).selvage null)).success;
in
{
  inherit
    c29Schema
    c29BobbinWith
    c29Bobbin
    c29KindTree
    c29KindTreeWithheld
    c29Bobbins
    c29Supplied
    c29Withheld
    ;
}

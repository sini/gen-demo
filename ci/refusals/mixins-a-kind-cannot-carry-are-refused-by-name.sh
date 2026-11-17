# shellcheck shell=bash
# ── mixins a kind cannot carry are refused BY NAME, never dropped (den-hoag-8kdu2; ADR-0025 item 1) ──
# Two doors in gen-schema's mixin pipeline, each planted. A schema built with `mkType` cannot take
# `mixins` (its result is the module an instance imports, so a mixin's module half has no place in
# it); a kind whose `baseModule` the record algebra cannot read (a function module) cannot run its
# mixins. Before, both served the kind with the mixin dropped. Each unplanted arm is the same schema
# without the plant and asserts a STDOUT VALUE, so a door refusing every kind cannot pass it.
# `mixins-without-a-base-are-carried` is the construct for the carried half.
row_mixins_a_kind_cannot_carry='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  schema = gen.lib.substrate.schema;
  merge = gen.lib.modules.merge;
  mx = schema.mkMixin { } (_: { mxo = merge.mkOption { type = merge.types.str; default = "m"; }; });
  mkTypeDefs = { defs, ... }: { __functor = _: { ... }: { imports = map (d: d.value) defs; }; };
  user = args: (merge.evalModuleTree { } [ { options.schema = schema.mkSchemaOption args; } { config.schema.user = { }; } ]).config.schema.user;
  mkTypeGreen = (user { mkType = mkTypeDefs; }).kind;
  mkTypeRed = (user { mkType = mkTypeDefs; mixins = [ mx ]; }).kind;
  baseGreen = builtins.toJSON (builtins.elem "mxo" (builtins.attrNames (user { baseModule = { }; mixins = [ mx ]; }).options));
  baseRed = builtins.toJSON (builtins.attrNames (user { baseModule = _: ({ ... }: { }); mixins = [ mx ]; }).options);
  caught = if (builtins.tryEval (user { mkType = mkTypeDefs; mixins = [ mx ]; }).kind).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 mixins-a-kind-cannot-carry unplanted (a schema built with mkType and no mixins is served)" \
  "${row_mixins_a_kind_cannot_carry/BODY/mkTypeGreen}" 0 "" "$tmpdir/mixins-a-kind-cannot-carry-mktype-green.err" 'user'
check "T5 mixins-a-kind-cannot-carry planted   (mixins on a schema built with mkType are refused by name)" \
  "${row_mixins_a_kind_cannot_carry/BODY/mkTypeRed}" 1 "gen-schema: a schema built with \`mkType\` cannot take \`mixins\`" \
  "$tmpdir/mixins-a-kind-cannot-carry-mktype-red.err"
check "T5 mixins-a-kind-cannot-carry unplanted (mixins over an attrset base are carried)" \
  "${row_mixins_a_kind_cannot_carry/BODY/baseGreen}" 0 "" "$tmpdir/mixins-a-kind-cannot-carry-base-green.err" 'true'
check "T5 mixins-a-kind-cannot-carry planted   (mixins over a function-module base are refused by name)" \
  "${row_mixins_a_kind_cannot_carry/BODY/baseRed}" 1 "gen-schema: kind 'user' declares mixins, and its baseModule is not an attrset (a lambda)" \
  "$tmpdir/mixins-a-kind-cannot-carry-base-red.err"
check "T5 mixins-a-kind-cannot-carry catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_mixins_a_kind_cannot_carry/BODY/caught}" 0 "" "$tmpdir/mixins-a-kind-cannot-carry-catch.err" 'CAUGHT'

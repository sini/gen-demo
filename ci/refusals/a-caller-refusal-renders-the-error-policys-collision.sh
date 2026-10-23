# shellcheck shell=bash
# ── a caller's `refusal` renders the `error` Merge Strategy's collision in the caller's own words
#    (gen-bind den-hoag-bind-error-describe-hook-gmji4). The `spool` binding collides with the
#    `spool` nixpkgs' `lib.evalModules` supplies through `_module.args`; the strategy is `error`, so
#    forcing `warnings` throws. The unplanted arm gives no `refusal` and asserts gen-bind's text;
#    the planted arm gives a framework's `refusal` and asserts the framework's text. Both throw, so
#    the text is the whole assertion: a door that ignored `refusal` passes the exit and fails the grep.
row_a_caller_refusal_renders_the_error_policys_collision='let
  inputs = (builtins.getFlake (toString ./.)).inputs;
  genBind = inputs.gen.lib.substrate.bind;
  lib = inputs.nixpkgs.lib;
  loom = name: _: "loom: class module arg ${name} collides with module-system arg -- set collisionPolicy to resolve";
  w = genBind.wrap ({ bindings.spool = "cotton"; defaultMergeStrategy = "error"; } // OPTS) ({ spool, ... }: { });
in builtins.deepSeq (lib.evalModules {
  modules = [ w.module w.validator { options.warnings = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ ]; }; config._module.args.spool = "linen"; } ];
}).config.warnings "ok"'
row_a_caller_refusal_renders_the_error_policys_collisionok="${row_a_caller_refusal_renders_the_error_policys_collision/OPTS/\{ \}}"
row_a_caller_refusal_renders_the_error_policys_collisionframework="${row_a_caller_refusal_renders_the_error_policys_collision/OPTS/\{ refusal = loom; \}}"
check "T5 a-caller-refusal-renders-the-error-policys-collision unplanted (no refusal; gen-bind's own text)" \
  "$row_a_caller_refusal_renders_the_error_policys_collisionok" 1 \
  "gen-bind: binding 'spool' collides with module-system arg — set mergeStrategy to resolve" \
  "$tmpdir/a-caller-refusal-green.err"
check "T5 a-caller-refusal-renders-the-error-policys-collision planted   (a framework's refusal; the framework's text, not gen-bind's)" \
  "$row_a_caller_refusal_renders_the_error_policys_collisionframework" 1 \
  "loom: class module arg spool collides with module-system arg -- set collisionPolicy to resolve" \
  "$tmpdir/a-caller-refusal-red.err"

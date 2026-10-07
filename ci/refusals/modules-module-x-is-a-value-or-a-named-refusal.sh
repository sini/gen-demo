# shellcheck shell=bash
# ── row 133 -- a module's `_module.<x>` is a value or a named refusal, never a silent drop (den-hoag-lnleu) ──
# gen-merge read only `_module.args` and `_module.freeformType` and dropped every other `_module`
# definition unread. An unknown sub-key is an option that does not exist (absorbed under a
# `freeformType`), and `specialArgs` is set by `evalModuleTree`'s caller, never by a module: each is a
# plant beside the door its message names. `check` is the option it is in nixpkgs, honoured at its
# own level: a module's `false` lists the undeclared key, and a module's `true` over the caller's
# `false` refuses it. Every unplanted arm asserts a STDOUT VALUE, so a reader that refused every
# `_module` cannot pass it.
row_modules_module_x_is_a_value_or_a_named_refusal='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  merge = gen.lib.modules.merge;
  t = merge.types;
  lazyRaw = t.lazyAttrsOf t.raw;
  readBogus = { config, ... }: { options.r = merge.mkOption { }; config.r = config._module.bogus or "ABSENT"; };
  readZ = { z, ... }: { options.r = merge.mkOption { }; config.r = z; };
  eval = modules: args: (merge.evalModuleTree args ([ { options.x = merge.mkOption { default = "x"; }; } ] ++ modules));
  absorbed = builtins.toJSON (eval [ { config._module.freeformType = lazyRaw; config._module.bogus = 1; } readBogus ] { }).config.r;
  unknown = builtins.toJSON (builtins.attrNames (eval [ { config._module.bogus = 1; } ] { }).config);
  doorArgs = builtins.toJSON (eval [ readZ ] { specialArgs.z = "door"; }).config.r;
  moduleArgs = builtins.toJSON (builtins.attrNames (eval [ { config._module.specialArgs.z = "module"; } ] { }).config);
  doorCheck = builtins.toJSON (map (u: u.path) (eval [ { y = 1; } ] { check = false; }).undeclared);
  checkFalseCfg = let r = eval [ { y = 1; } { config._module.check = false; } ] { }; in builtins.toJSON { und = map (u: u.path) r.undeclared; names = builtins.attrNames r.config; };
  checkTrueCallerFalse = builtins.toJSON (builtins.attrNames (eval [ { y = 1; } { config._module.check = true; } ] { check = false; }).config);
in BODY'
check "T5 modules-module-x-is-a-value-or-a-named-refusal unplanted (an unknown _module sub-key under a freeformType is absorbed and read back)" \
  "${row_modules_module_x_is_a_value_or_a_named_refusal/BODY/absorbed}" 0 "" "$tmpdir/modules-module-x-is-a-value-or-a-named-refusal-absorbed.err" '1'
check "T5 modules-module-x-is-a-value-or-a-named-refusal planted   (an unknown _module sub-key is an option that does not exist)" \
  "${row_modules_module_x_is_a_value_or_a_named_refusal/BODY/unknown}" 1 \
  "The option \`_module.bogus' does not exist" "$tmpdir/modules-module-x-is-a-value-or-a-named-refusal-unknown.err"
check "T5 modules-module-x-is-a-value-or-a-named-refusal planted   (the unknown _module sub-key is offered the engine's own _module options, as nixpkgs does)" \
  "${row_modules_module_x_is_a_value_or_a_named_refusal/BODY/unknown}" 1 \
  "Did you mean \`_module.args', \`_module.check' or \`_module.specialArgs'?" "$tmpdir/modules-module-x-is-a-value-or-a-named-refusal-unknown-suggestion.err"
check "T5 modules-module-x-is-a-value-or-a-named-refusal unplanted (specialArgs passed at the evalModuleTree door reach a module)" \
  "${row_modules_module_x_is_a_value_or_a_named_refusal/BODY/doorArgs}" 0 "" "$tmpdir/modules-module-x-is-a-value-or-a-named-refusal-door-args.err" '"door"'
check "T5 modules-module-x-is-a-value-or-a-named-refusal planted   (a module setting _module.specialArgs is refused by name)" \
  "${row_modules_module_x_is_a_value_or_a_named_refusal/BODY/moduleArgs}" 1 \
  "\`_module.specialArgs' is set by the caller, never by a module" "$tmpdir/modules-module-x-is-a-value-or-a-named-refusal-module-args.err"
check "T5 modules-module-x-is-a-value-or-a-named-refusal unplanted (check = false at the evalModuleTree door lists the undeclared key)" \
  "${row_modules_module_x_is_a_value_or_a_named_refusal/BODY/doorCheck}" 0 "" "$tmpdir/modules-module-x-is-a-value-or-a-named-refusal-door-check.err" '[["y"]]'
check "T5 modules-module-x-is-a-value-or-a-named-refusal unplanted (a module's _module.check = false lists the undeclared key, as nixpkgs drops it)" \
  "${row_modules_module_x_is_a_value_or_a_named_refusal/BODY/checkFalseCfg}" 0 "" "$tmpdir/modules-module-x-is-a-value-or-a-named-refusal-check-false.err" '{"names":["x"],"und":[["y"]]}'
check "T5 modules-module-x-is-a-value-or-a-named-refusal planted   (a module's _module.check = true outranks the caller's check = false and refuses the undeclared key)" \
  "${row_modules_module_x_is_a_value_or_a_named_refusal/BODY/checkTrueCallerFalse}" 1 \
  "The option \`y' does not exist" "$tmpdir/modules-module-x-is-a-value-or-a-named-refusal-check-true.err"

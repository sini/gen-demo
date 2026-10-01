# shellcheck shell=bash
# ── row 133 -- a module's `_module.<x>` is a value or a named refusal, never a silent drop (den-hoag-lnleu) ──
# gen-merge read only `_module.args` and `_module.freeformType` and dropped every other `_module`
# definition unread. Three plants, each beside the door its message names: an unknown sub-key is an
# option that does not exist (absorbed under a `freeformType`), and `specialArgs` and `check` are set
# by `evalModuleTree`'s caller, never by a module. Every unplanted arm asserts a STDOUT VALUE read
# through the door the refusal points at, so a reader that refused every `_module` cannot pass it.
row133='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  merge = gen.lib.modules.merge;
  t = merge.types;
  lazyRaw = t.lazyAttrsOf t.raw;
  readBogus = { config, ... }: { options.r = merge.mkOption { }; config.r = config._module.bogus or "ABSENT"; };
  readZ = { z, ... }: { options.r = merge.mkOption { }; config.r = z; };
  eval = modules: args: (merge.evalModuleTree ({ modules = [ { options.x = merge.mkOption { default = "x"; }; } ] ++ modules; } // args));
  absorbed = builtins.toJSON (eval [ { config._module.freeformType = lazyRaw; config._module.bogus = 1; } readBogus ] { }).config.r;
  unknown = builtins.toJSON (builtins.attrNames (eval [ { config._module.bogus = 1; } ] { }).config);
  doorArgs = builtins.toJSON (eval [ readZ ] { specialArgs.z = "door"; }).config.r;
  moduleArgs = builtins.toJSON (builtins.attrNames (eval [ { config._module.specialArgs.z = "module"; } ] { }).config);
  doorCheck = builtins.toJSON (map (u: u.path) (eval [ { y = 1; } ] { check = false; }).undeclared);
  moduleCheck = builtins.toJSON (builtins.attrNames (eval [ { y = 1; } { config._module.check = false; } ] { }).config);
in BODY'
check "T5 row133 unplanted (an unknown _module sub-key under a freeformType is absorbed and read back)" \
  "${row133/BODY/absorbed}" 0 "" "$tmpdir/row133-absorbed.err" '1'
check "T5 row133 planted   (an unknown _module sub-key is an option that does not exist)" \
  "${row133/BODY/unknown}" 1 \
  "option \`_module.bogus' does not exist (no freeformType to absorb it)" "$tmpdir/row133-unknown.err"
check "T5 row133 unplanted (specialArgs passed at the evalModuleTree door reach a module)" \
  "${row133/BODY/doorArgs}" 0 "" "$tmpdir/row133-door-args.err" '"door"'
check "T5 row133 planted   (a module setting _module.specialArgs is refused by name)" \
  "${row133/BODY/moduleArgs}" 1 \
  "\`_module.specialArgs' is set by the caller, never by a module" "$tmpdir/row133-module-args.err"
check "T5 row133 unplanted (check = false at the evalModuleTree door lists the undeclared key)" \
  "${row133/BODY/doorCheck}" 0 "" "$tmpdir/row133-door-check.err" '[["y"]]'
check "T5 row133 planted   (a module setting _module.check is refused by name)" \
  "${row133/BODY/moduleCheck}" 1 \
  "\`_module.check' is not read from a module" "$tmpdir/row133-module-check.err"

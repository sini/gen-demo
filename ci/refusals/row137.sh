# shellcheck shell=bash
# ── row 137 -- an engine-owned `_module.<k>` re-declared takes nixpkgs' value or a named refusal
#    (den-hoag-module-decl-shapes-parity-wv300; ADR-0025 item 1) ──
# nixpkgs merges its own `_module` options with a module's declarations. A `submodule`-typed
# `options._module` takes every `_module.<x>` the engine does not own, and an `apply` on `args` inside
# it maps the merged set; gen-merge refused the leaf as a single option. An owned key re-declared with
# a type that does not merge with the engine's own, or as a group of options, is refused by name,
# where gen-merge left the declaration silently inert. Every unplanted arm asserts a STDOUT VALUE, so a
# reader that refused every `options._module` cannot pass it.
row137='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  merge = gen.lib.modules.merge;
  t = merge.types;
  readSeam = { config, sateen, ... }: { options.seam = merge.mkOption { }; config.seam = [ config._module.weft sateen ]; };
  leaf = extra: builtins.toJSON (merge.evalModuleTree { } [
    { options._module = merge.mkOption { type = t.submodule { options = { weft = merge.mkOption { default = 1; }; } // extra; }; default = { }; };
      config._module.weft = 2; config._module.args.sateen = "P"; }
    readSeam
  ]).config.seam;
  rest = leaf { };
  mapped = leaf { args = merge.mkOption { apply = a: a // { sateen = "Q"; }; }; };
  redeclared = mods: builtins.toJSON (builtins.attrNames (merge.evalModuleTree { } ([ { options.x = merge.mkOption { default = "x"; }; } ] ++ mods)).config);
  typed = redeclared [ { options._module.args = merge.mkOption { type = t.attrsOf t.int; }; config._module.args.sateen = "P"; } ];
  group = redeclared [ { options._module.args.foo = merge.mkOption { type = t.int; }; } ];
in BODY'
check "T5 row137 unplanted (a submodule-typed options._module takes the rest and still serves _module.args)" \
  "${row137/BODY/rest}" 0 "" "$tmpdir/row137-rest.err" '[2,"P"]'
check "T5 row137 unplanted (an apply on args inside the leaf maps the merged set)" \
  "${row137/BODY/mapped}" 0 "" "$tmpdir/row137-mapped.err" '[2,"Q"]'
check "T5 row137 planted   (an owned key re-declared with another type is refused by name)" \
  "${row137/BODY/typed}" 1 \
  "is already declared by the engine's own \`_module' options" "$tmpdir/row137-typed.err"
check "T5 row137 planted   (an owned key declared as a group is refused by name)" \
  "${row137/BODY/group}" 1 \
  "cannot be the parent of \`_module.args.foo'" "$tmpdir/row137-group.err"

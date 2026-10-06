# shellcheck shell=bash
# ── row 163 -- a functor-form module function at an aspect position is refused BY NAME, where it was
#    read as config and the class value came back null (den-hoag-a3eys) ──
# `lib.setFunctionArgs` builds `{ __functionArgs; __functor; }`, an attrset, so a submodule reads it as
# CONFIG: its two keys landed in the aspect's freeform slot and `nixos` stayed null with no error. The
# planted arm writes that shape at an aspect; the unplanted arm writes its lambda twin, which is served,
# so a type that refused every module function cannot pass it, and a type that dropped the class value
# (`null`, which `deepSeq` forces without error) prints `dropped`, not `delivered`.
# Numbered row 162 on its branch; renumbered row 163 at relock 65, past 5n8ey's row 162.
row163='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAspects = gen.lib.aspects.aspects;
  genMerge = gen.lib.modules.merge;
  cnf = {
    entityKinds = null;
    keySemantics.nixos.category = "class";
    moduleArgs = { config = true; pkgs = true; };
  };
  schema = genAspects.mkAspectSchema cnf;
  cls = { nixos = { pkgs, ... }: { marker = "seam"; }; };
  twin = { config, ... }: cls;
  functor = { __functionArgs = { config = false; }; __functor = _: { config, ... }: cls; };
  main = d:
    (genMerge.evalModuleTree { } [
      { options.aspects = schema.mkAspectOption { }; }
      { config.aspects.main = d; }
    ]).config.aspects.main;
  served = d: let v = (main d).nixos; in if v == null then "dropped" else builtins.deepSeq v "delivered";
  lambda = served twin;
  refused = served functor;
in BODY'
check "T5 row163 unplanted (the lambda twin of a module function is served)" \
  "${row163/BODY/lambda}" 0 "" "$tmpdir/row163-green.err" "delivered"
check "T5 row163 planted   (a functor-form module function at an aspect is refused by name)" \
  "${row163/BODY/refused}" 1 \
  'a functor-form module function (an attrset with `__functor`, as `setFunctionArgs` builds) reached an aspect position' \
  "$tmpdir/row163-planted.err"

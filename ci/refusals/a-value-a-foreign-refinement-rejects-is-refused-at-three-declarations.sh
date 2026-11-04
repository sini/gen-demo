# shellcheck shell=bash
# ── a value a foreign self-answering refinement rejects is refused at three declarations (gen-merge den-hoag-ob4k0) ──
# A nixpkgs `int` refinement whose `typeMerge` answers its own tree (`type = _: self`) and a second
# construction of the same name and payload, declared beside gen's `int`: at the third declaration the
# fold's first step joined the refinement's tree, and the declaration it met was not owed whole, so the
# value either refinement rejects was served, in an order-dependent way (declared gen, 7-refusing,
# 9-refusing it served 7; gen, 9-refusing, 7-refusing it served 9). The declaration is owed whole there,
# and the value is refused in every order. The unplanted arm is the value both admit (8), so a library
# refusing every such trio cannot pass it; the planted arms exit 1, so a fold serving the value cannot.
row_a_value_a_foreign_refinement_rejects_is_refused_at_three_declarations='let
  flake = builtins.getFlake (toString ./.);
  genMerge = flake.inputs.gen.lib.modules.merge;
  lib = flake.inputs.nixpkgs.lib;
  rejecting = n:
    let
      self = lib.mkOptionType {
        name = "int";
        check = x: builtins.isInt x && x != n;
        merge = lib.options.mergeEqualOption;
        functor = lib.types.defaultFunctor "int" // {
          type = _: self;
          payload = { refined = true; };
          binOp = a: _b: a;
        };
        typeMerge = f:
          if f.name == "int" && (f.payload == null || f.payload == { refined = true; })
          then self
          else null;
      };
    in self;
in toString (genMerge.evalModuleTree { } [
    { _file = "/demo/lens-a.nix"; options.lens.focus = genMerge.mkOption { type = FIRST; }; }
    { _file = "/demo/lens-b.nix"; options.lens.focus = genMerge.mkOption { type = SECOND; }; }
    { _file = "/demo/lens-c.nix"; options.lens.focus = genMerge.mkOption { type = THIRD; }; }
    { _file = "/demo/lens.nix"; lens.focus = VALUE; }
  ]).config.lens.focus'
row_a_value_a_foreign_refinement_rejects_is_refused_at_three_declarationsgab="${row_a_value_a_foreign_refinement_rejects_is_refused_at_three_declarations/FIRST/genMerge.types.int}"
row_a_value_a_foreign_refinement_rejects_is_refused_at_three_declarationsgab="${row_a_value_a_foreign_refinement_rejects_is_refused_at_three_declarationsgab/SECOND/rejecting 7}"
row_a_value_a_foreign_refinement_rejects_is_refused_at_three_declarationsgab="${row_a_value_a_foreign_refinement_rejects_is_refused_at_three_declarationsgab/THIRD/rejecting 9}"
row_a_value_a_foreign_refinement_rejects_is_refused_at_three_declarationsgba="${row_a_value_a_foreign_refinement_rejects_is_refused_at_three_declarations/FIRST/genMerge.types.int}"
row_a_value_a_foreign_refinement_rejects_is_refused_at_three_declarationsgba="${row_a_value_a_foreign_refinement_rejects_is_refused_at_three_declarationsgba/SECOND/rejecting 9}"
row_a_value_a_foreign_refinement_rejects_is_refused_at_three_declarationsgba="${row_a_value_a_foreign_refinement_rejects_is_refused_at_three_declarationsgba/THIRD/rejecting 7}"
check "T5 a-value-a-foreign-refinement-rejects-is-refused-at-three-declarations unplanted (gen, 7-refusing, 9-refusing, 8: the value both admit is served)" "${row_a_value_a_foreign_refinement_rejects_is_refused_at_three_declarationsgab/VALUE/8}" 0 "" \
  "$tmpdir/a-value-a-foreign-refinement-rejects-is-refused-at-three-declarations-green.err" '8'
check "T5 a-value-a-foreign-refinement-rejects-is-refused-at-three-declarations planted   (gen, 7-refusing, 9-refusing, 7: refused, not served)" "${row_a_value_a_foreign_refinement_rejects_is_refused_at_three_declarationsgab/VALUE/7}" 1 \
  "gen-merge: a definition for option \`lens.focus' is not of type" \
  "$tmpdir/a-value-a-foreign-refinement-rejects-is-refused-at-three-declarations-red.err"
check "T5 a-value-a-foreign-refinement-rejects-is-refused-at-three-declarations planted   (gen, 9-refusing, 7-refusing, 9: refused in the other order)" "${row_a_value_a_foreign_refinement_rejects_is_refused_at_three_declarationsgba/VALUE/9}" 1 \
  "gen-merge: a definition for option \`lens.focus' is not of type" \
  "$tmpdir/a-value-a-foreign-refinement-rejects-is-refused-at-three-declarations-red-ba.err"

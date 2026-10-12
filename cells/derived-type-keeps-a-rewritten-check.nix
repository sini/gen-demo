# `derived-type-keeps-a-rewritten-check` — den-hoag-vtfqp. `np.addCheck` over a gen module-set type
# states a check on a record whose checked fold is the plain one: the rewritten check lives in the
# `check` field and nowhere else. gen-merge's `deriveType` over it cut that field, and the derivation
# served the value its base refuses. Here `deriveType` over `addCheck` of an `attrsOf` of a gen
# `submodule` (the arm that discriminates on every gen-merge revision) and over `addCheck` of the
# bare `submodule`, declared once and twice, refuses `{ a = 1; }` and serves `{ a = 2; }`. Live
# controls: the derivation over the UNREWRITTEN base serves `{ a = 1; }`, and the underived copy
# refuses it, so a derivation refusing everything, or a copy that never refused, cannot pass.
{
  asserts,
  genMerge,
  inputs,
}:
{
  construct = [ "derived-type-keeps-a-rewritten-check" ];
  check = asserts (
    let
      inherit (genMerge) deriveType evalModuleTree mkOption;
      t = genMerge.types;
      np = inputs.nixpkgs.lib.types;
      sub = t.submodule { options.a = mkOption { type = t.int; }; };
      derive = deriveType { key = "k"; } "d";
      # whether the declarations serve the value
      read =
        decls: v:
        let
          o = builtins.tryEval (
            builtins.deepSeq
              (evalModuleTree { } (map (T: { options.x = mkOption { type = T; }; }) decls ++ [ { x = v; } ]))
              .config.x
              null
          );
        in
        o.success;
      shapes = {
        attrs = {
          base = t.attrsOf sub;
          ok = {
            k = {
              a = 2;
            };
          };
          bad = {
            k = {
              a = 1;
            };
          };
        };
        bare = {
          base = sub;
          ok = {
            a = 2;
          };
          bad = {
            a = 1;
          };
        };
      };
      isBad = v: v == 1 || (builtins.isAttrs v && builtins.any isBad (builtins.attrValues v));
      rewritten = S: np.addCheck S.base (v: !(isBad v));
      per =
        S:
        let
          c = rewritten S;
          d = derive c;
        in
        # the derivation, declared once and twice (two separate constructions)
        read [ d ] S.ok
        && !(read [ d ] S.bad)
        && read [ d d ] S.ok
        && !(read [ d d ] S.bad)
        && read [ d (derive c) ] S.ok
        && !(read [ d (derive c) ] S.bad)
        # controls: the underived copy refuses, the derivation over the unrewritten base serves
        && read [ c ] S.ok
        && !(read [ c ] S.bad)
        && read [ (derive S.base) ] S.bad;
    in
    per shapes.attrs && per shapes.bare
  );
}

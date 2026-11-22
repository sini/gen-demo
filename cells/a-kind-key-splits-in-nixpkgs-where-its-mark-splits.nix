# `a-kind-key-splits-in-nixpkgs-where-its-mark-splits` — den-hoag-y9j03. One declaration literal of a kind `gusset` under two schemas that differ in one
# construction parameter is one declaration node, and nixpkgs' `lib.evalModules` keeps one module per
# reference key, so each pair reads how many constructions nixpkgs kept: two where the marks differ, one
# where they agree. The key reads the base and the mixins as the def they resolve to, a sealed parameter
# per leaf, the declaration's open paths, and no module index, so it splits exactly where the mark splits.
# Before, the mixins, a function base, a sealed keySemantics leaf and an open config path each kept ONE
# of two constructions the mark tells apart (nixpkgs dropped the other silently), and two import orders of
# one declaration kept both of two constructions the mark identifies.
{
  asserts,
  genMerge,
  genSchema,
  lib,
}:
let
  T = genMerge.types;
  str =
    d:
    genMerge.mkOption {
      type = T.str;
      default = d;
    };
  # one kind `gusset` from ONE declaration literal under each schema; the declaration states one
  # entry of a list a sibling module declares, so nixpkgs' `lib.evalModules` shows how many
  # constructions it kept: one entry per kept construction
  gussetOf =
    args: decl:
    (genMerge.evalModuleTree { } [
      { options.schema = genSchema.mkSchemaOption args; }
      { config.schema.gusset = decl; }
    ]).config.schema.gusset;
  tally = {
    options.seen = lib.mkOption { type = lib.types.listOf lib.types.str; };
    options.pile = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
  };
  # how many constructions nixpkgs keeps of the pair (tryEval: a doubled declaration refuses)
  kept =
    a: b:
    let
      r = builtins.tryEval (
        builtins.length
          (lib.evalModules {
            modules = [
              tally
              a
              b
            ];
          }).config.seen
      );
    in
    if r.success then r.value else "refused";
  seen = {
    config.seen = [ "gusset" ];
  };
  nap = genSchema.mkMixin { } (_: {
    nap = str "a";
  });
  noop = genSchema.mkMixin { } (_: { });
  fnBase = o: _: { options.${o} = str o; };
  sealed = _: null;
  withPile = p: {
    config = {
      seen = [ "gusset" ];
    }
    // (if p then { pile = "x"; } else { });
  };
  ordered =
    pq:
    let
      p = {
        options.p = str "p";
      };
      q = {
        options.q = str "q";
      };
    in
    {
      imports =
        if pq then
          [
            p
            q
          ]
        else
          [
            q
            p
          ];
      config.seen = [ "gusset" ];
    };
  oneLiteral = f: x: f x;
in
{
  construct = [ "a-kind-key-splits-in-nixpkgs-where-its-mark-splits" ];
  check = asserts (
    kept (gussetOf { mixins = [ noop ]; } seen) (gussetOf { mixins = [ nap ]; } seen) == 2
    &&
      kept (gussetOf { baseModule = fnBase "nap"; } seen) (gussetOf { baseModule = fnBase "wale"; } seen)
      == 2
    &&
      kept
        (gussetOf {
          keySemantics = {
            f = sealed;
            c = "a";
          };
        } seen)
        (
          gussetOf {
            keySemantics = {
              f = sealed;
              c = "b";
            };
          } seen
        ) == 2
    && kept (gussetOf { } (oneLiteral withPile false)) (gussetOf { } (oneLiteral withPile true)) == 2
    && kept (gussetOf { } (oneLiteral ordered true)) (gussetOf { } (oneLiteral ordered false)) == 1
  );
}

# ── a gen type with no nixpkgs twin STATES the base module args it refuses from a caller (den-hoag-58bib β) ──
# gen-merge serves a caller's `config`, `options` and `prefix` as nixpkgs serves them (ADR-0039). A type of
# gen's own that supplies one of them from its own evaluation states it with `refusingSubmodule`, and
# gen-merge then refuses that key by name, on presence, wherever a caller's args join the type: its
# `withArgs`, and a redeclaration's union in either order. A fresh key (`argand`) is still served on both
# routes, which says the refusal is the stated key's and not the channel's. The plain `submodule` twin
# states nothing, and the two mint apart.
{ genMerge }:
let
  refusingTypeOf = genMerge.refusingSubmodule [ "config" ] (
    { argand, ... }:
    {
      options.a = genMerge.mkOption {
        type = genMerge.types.int;
        default = argand;
      };
    }
  );
  plainTwin = genMerge.types.submodule [ ];
  at = decls: (genMerge.evalModuleTree { } decls).config.h;
  opt = t: {
    options.h = genMerge.mkOption {
      type = t;
      default = { };
    };
  };
  refused = e: !(builtins.tryEval (builtins.deepSeq e e)).success;
  callerConfig = {
    config = { };
    argand = 2;
  };
in
{
  refusingTypeArms = {
    stated = refusingTypeOf.refusedArgs;
    twinStatesNone = !(plainTwin ? refusedArgs);
    mintsApart = refusingTypeOf.__mint != plainTwin.__mint;
    withArgsRefused = refused (at [ (opt (refusingTypeOf.withArgs callerConfig)) ]);
    redeclarationRefused = refused (at [
      (opt refusingTypeOf)
      (opt (plainTwin.withArgs callerConfig))
    ]);
    redeclarationReversedRefused = refused (at [
      (opt (plainTwin.withArgs callerConfig))
      (opt refusingTypeOf)
    ]);
    withArgsServesArgand = (at [ (opt (refusingTypeOf.withArgs { argand = 2; })) ]).a;
    redeclarationServesArgand =
      (at [
        (opt refusingTypeOf)
        (opt (plainTwin.withArgs { argand = 2; }))
      ]).a;
  };
}

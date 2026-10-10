# `declaration-read-syntax` — C40, den-hoag-4kw63. gen-merge refuses a module's syntax on each
# door's first read, which for `declaredOptions` is the declaration stratum. C35's typo module, read
# for its declarations only, is refused by name, where the read used to answer `[ "spool" ]` and
# drop `weft` without a word. The spelled-right twin reads `[ "_module" "spool" "weft" ]` beside it,
# the engine's `_module` records with its two options, as nixpkgs' `evalModules` reads it
# (den-hoag-a67l3); the message is `refusals` row 35.
#
# C40 — den-hoag-4kw63: gen-merge refuses a module's syntax on its first read, so
# a DECLARATION-only read of C35's typo module refuses by name, as a config read does,
# where `declaredOptions` used to answer `[ "spool" ]` and drop `weft` unread. The
# spelled-right twin is read beside it, so a reader refusing every module cannot pass.
{ asserts, genMerge }:
{
  construct = [ "declaration-read-refuses-module-syntax" ];
  check = asserts (
    let
      spoolOpt = genMerge.mkOption {
        type = genMerge.types.str;
        default = "none";
      };
      declared = m: builtins.attrNames (genMerge.declaredOptions { } [ m ]);
      typo = {
        _file = "/demo/typo.nix";
        options.spool = spoolOpt;
        option.weft = spoolOpt;
      };
    in
    !(builtins.tryEval (declared typo)).success
    &&
      declared (
        removeAttrs typo [ "option" ]
        // {
          options = {
            spool = spoolOpt;
            weft = spoolOpt;
          };
        }
      ) == [
        "_module"
        "spool"
        "weft"
      ]
  );
}

# `module-reader-syntax` — C35, den-hoag-s7826. gen-merge reads a module's keys the way nixpkgs'
# `unifyModuleSyntax` does. A shorthand key beside `imports` is config: `spool` reads `sateen`,
# where the key used to be dropped unread and the option kept its default. A surplus key beside an
# explicit `config` is refused, beside the same module without that key reading `sateen`, so a
# reader refusing every module cannot pass; the message is `refusals` row 31's.
#
# C35 — ADR-0025 item 1 on the module reader (den-hoag-s7826): gen-merge
# classifies a module's keys the way nixpkgs' `unifyModuleSyntax` does. A shorthand
# key beside `imports` is CONFIG, where it used to be dropped unread and the option
# kept its default; a surplus key beside an explicit `config` is refused (by name in
# `refusals` row 31). The refusal is read beside its control with the surplus key
# removed, so a reader refusing every module cannot pass this cell.
{ asserts, genMerge }:
{
  construct = [ "C35" ];
  check = asserts (
    let
      read =
        m:
        (genMerge.evalModuleTree {
          modules = [
            {
              options.spool = genMerge.mkOption {
                type = genMerge.types.str;
                default = "none";
              };
            }
            m
          ];
        }).config.spool;
      typo = {
        _file = "/demo/typo.nix";
        config.spool = "sateen";
        spol = 1;
      };
    in
    read {
      imports = [ ];
      spool = "sateen";
    } == "sateen"
    && !(builtins.tryEval (read typo)).success
    && read (removeAttrs typo [ "spol" ]) == "sateen"
  );
}

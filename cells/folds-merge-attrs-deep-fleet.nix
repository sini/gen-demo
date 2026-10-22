# `folds-merge-attrs-deep-fleet` — den-hoag-izo7a. Three fleet fragments, two hosts writing
# `nixosConfigurations.<h>`, `deploy.nodes.<h>.hostname` and `colmena.<h>`, and a third repeating
# one equal leaf, join under `folds.mergeAttrsDeep` into one record at every depth; the equal leaf
# collapses, and a lone contributor is never forced.
#
# Red before gen-scope had the fold: `folds ? mergeAttrsDeep` was false. Live control: the shallow
# `folds.mergeAttrs` refuses the same fragments on the shared sub-key `nixosConfigurations`.
{ asserts, genScope }:
{
  construct = [ "a-deep-attrs-fold-joins-a-fleet" ];
  check = asserts (
    let
      inherit (genScope) folds;
      fleet = [
        {
          nixosConfigurations.h1 = "sys1";
          deploy.nodes.h1.hostname = "a";
          colmena.h1 = "c1";
        }
        {
          nixosConfigurations.h2 = "sys2";
          deploy.nodes.h2.hostname = "b";
          colmena.h2 = "c2";
        }
        { deploy.nodes.h1.hostname = "a"; }
      ];
      # Each fragment is a contributor edge, `{ site; value; }` (gen-scope's fold contract).
      edges =
        vs:
        builtins.genList (i: {
          site = "fragment ${toString i}";
          value = builtins.elemAt vs i;
        }) (builtins.length vs);
    in
    folds.mergeAttrsDeep "k" (edges fleet) == {
      colmena = {
        h1 = "c1";
        h2 = "c2";
      };
      deploy.nodes = {
        h1.hostname = "a";
        h2.hostname = "b";
      };
      nixosConfigurations = {
        h1 = "sys1";
        h2 = "sys2";
      };
    }
    &&
      builtins.attrNames (
        folds.mergeAttrsDeep "k" (edges [
          { a.x = throw "never forced"; }
          { b = 1; }
        ])
      ) == [
        "a"
        "b"
      ]
    && !(builtins.tryEval (builtins.deepSeq (folds.mergeAttrs "k" (edges fleet)) null)).success
  );
}

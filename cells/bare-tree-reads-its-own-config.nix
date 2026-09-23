# `bare-tree-reads-its-own-config` — C47, den-hoag-tgj54. A `check = true` tree typed bare whose
# leaf `sub` is another tree, defined `sub = mkIf config.bolt.flag { k = "s"; }`, reads `sub.k =
# "s"`, where the orphan gate forced the config the `mkIf` reads and the evaluation aborted with
# infinite recursion. An undeclared `sub.bogus` is refused when read deep and is a value at a
# sibling read (`known = "v"`), and `.undeclared` names it. A strict warm evaluation over a lax
# prior refuses it deep and reads `warmDecision.mode == "cold"` with its reason; a lax warm
# evaluation over a strict prior is the cold value.
#
# C47 — den-hoag-tgj54: a nested tree typed BARE reads its own config lazily. A
# `check = true` tree's `sub` leaf is another tree defined `mkIf config.bolt.flag …`,
# which aborted uncatchably with infinite recursion because the orphan gate was
# seq'd onto the config the `mkIf` reads. The gate now decides its own level only:
# an undeclared key one level down is refused when read deep and is a value at a
# sibling read, and `.undeclared` names it, so a reader refusing everything and one
# refusing nothing both fail. A warm evaluation keys on the effective strictness:
# strict over a lax prior refuses deep and says why it went cold; lax over a strict
# prior is the cold value.
{ asserts, genMerge }:
{
  construct = [ "C47" ];
  check = asserts (
    let
      inherit (genMerge) evalModuleTree mkOption mkIf;
      t = genMerge.types;
      forces = e: (builtins.tryEval (builtins.deepSeq e null)).success;
      liningOf =
        check:
        (evalModuleTree {
          inherit check;
          modules = [
            {
              options.k = mkOption {
                type = t.str;
                default = "d";
              };
            }
          ];
        }).type;
      boltOf =
        check:
        (evalModuleTree {
          inherit check;
          modules = [
            {
              options.known = mkOption {
                type = t.str;
                default = "k";
              };
              options.flag = mkOption {
                type = t.bool;
                default = false;
              };
              options.sub = mkOption { type = liningOf check; };
            }
          ];
        }).type;
      run =
        check: ty: m:
        evalModuleTree {
          inherit check;
          modules = [
            { options.bolt = mkOption { type = ty; }; }
            m
          ];
        };
      selfRef =
        { config, ... }:
        {
          config.bolt = {
            known = "v";
            flag = true;
            sub = mkIf config.bolt.flag { k = "s"; };
          };
        };
      subBad = {
        _file = "/corpus/bolt.nix";
        config.bolt = {
          known = "v";
          sub = {
            k = "s";
            bogus = 1;
          };
        };
      };
      edited = [
        {
          options.other = mkOption { type = t.str; };
          config.other = "o";
        }
      ];
      base = [
        { options.bolt = mkOption { type = boltOf false; }; }
        subBad
      ];
      warmAt =
        prev: next:
        evalModuleTree {
          check = next;
          modules = base ++ edited;
          warmFrom = evalModuleTree {
            check = prev;
            modules = base;
          };
          editedModules = edited;
        };
      coldLax = evalModuleTree {
        check = false;
        modules = base ++ edited;
      };
      strictOverLax = warmAt false true;
    in
    (run true (boltOf true) selfRef).config.bolt.sub.k == "s"
    && !(forces (run true (boltOf false) subBad).config)
    && (run true (boltOf false) subBad).config.bolt.known == "v"
    &&
      map (u: u.path) (run true (boltOf false) subBad).undeclared == [
        [
          "bolt"
          "sub"
          "bogus"
        ]
      ]
    && !(forces strictOverLax.config)
    && strictOverLax.warmDecision.mode == "cold"
    && strictOverLax.warmDecision.reason == "check differs from warmFrom's (warm refused)"
    && (warmAt true false).config.bolt == coldLax.config.bolt
  );
}

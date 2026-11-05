# `a-staged-nested-child-collects-once-per-environment` — den-hoag-staged-stratum-inner-eval-nhjxu (B1). A gen-native
# nested tree whose child's declaration reads `options` in its own shape (so the child's spine does not resolve and its
# staged passes run) serves the child's values, at one level and at two, as the same modules do at the root. The child
# is a LOCATED evaluation that takes the passes: its guard, value stratum and levels collect in one environment and its
# passes in another, and each environment decides its closure (keys, dedup, order) once while every other walk
# re-applies along it. A keyed import (`imp` importing `leaf`) and a key shared across levels sit in every child, so
# the decision is a keyed one.
{ asserts, genMerge }:
{
  construct = [ "a-staged-nested-child-collects-once-per-environment" ];
  check = asserts (
    let
      inherit (genMerge) evalModuleTree mkOption;
      t = genMerge.types;
      plain = {
        key = "plain";
        options.a = mkOption {
          type = t.int;
          default = 0;
        };
        config.b = 2;
        options.c = mkOption {
          type = t.int;
          default = 0;
        };
      };
      leaf = {
        key = "leaf";
        options.b = mkOption { type = t.int; };
      };
      imp = {
        key = "imp";
        imports = [ leaf ];
        config.a = 1;
      };
      # its declaration's shape reads `options.a`, so the spine leaves `d` pending and the passes resolve it
      staged =
        { options, ... }:
        {
          options.d =
            mkOption { default = 5; } // (if options.a.type != null then { type = options.a.type; } else { });
        };
      child = [
        plain
        imp
        staged
      ];
      hostOf = modules: {
        options.sub = mkOption {
          type = t.submodule modules;
          default = { };
        };
        config.sub.c = 4;
      };
      one = (evalModuleTree { } [ (hostOf child) ]).config.sub;
      two = (evalModuleTree { } [ (hostOf (child ++ [ (hostOf child) ])) ]).config.sub;
      root = (evalModuleTree { } child).config;
    in
    one == {
      a = 1;
      b = 2;
      c = 4;
      d = 5;
    }
    && two.sub == one
    && removeAttrs two [ "sub" ] == one
    &&
      root == {
        a = 1;
        b = 2;
        c = 0;
        d = 5;
      }
  );
}

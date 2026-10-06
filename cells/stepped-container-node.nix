# `stepped-container-node` — container-of-trees-below-a-step-under-any-over-approximating-container-serves, den-hoag-t1j4z Case B (ADR-0039, the serve half). A gen container of
# nested trees BELOW A STEP under an over-approximating container other than `lazyAttrsOf` is a
# container node, and its own fold reads it wherever gen-merge's key walk minted one, so it serves
# nixpkgs' value where it was refused by name (S1 class (a)). Two such containers: a consumer's stepped
# `defineType` container in gen-aspects' `aspectsRootWith` shape (each element re-rooted at `[ k ]`,
# folded through the threaded twin over the accessor it was handed), whose fold sets no mark, beside a
# sibling whose key set reads the read tree; and nixpkgs' lazy `attrsWith` under `uniq`.

{
  asserts,
  genMerge,
  lib,
}:

let
  t = genMerge.types;
  sub = t.submodule { options.x = genMerge.mkOption { type = t.int; }; };
  stepRoot =
    elemType:
    let
      split =
        _loc: defs:
        map (k: {
          step = [ k ];
          loc = [ k ];
          defs = builtins.concatMap (
            d:
            lib.optional (d.value ? ${k}) {
              inherit (d) file;
              value = d.value.${k};
            }
          ) defs;
          type = elemType;
        }) (builtins.attrNames (builtins.foldl' (acc: d: acc // d.value) { } defs));
      foldWith =
        foldElement: loc: defs:
        builtins.listToAttrs (
          map (e: {
            name = builtins.head e.step;
            value = foldElement e;
          }) (split loc defs)
        );
    in
    t.defineType {
      name = "stepRoot";
      inherit elemType split;
      carries.element = elemType;
      recarry = c: stepRoot c.element;
      substructure = {
        declares = prefix: elemType.getSubOptions (prefix ++ [ "<name>" ]);
        modules = elemType.getSubModules or null;
        rebuild = m: stepRoot (if elemType ? substSubModules then elemType.substSubModules m else elemType);
      };
      mergeDefs = {
        __functor = _: foldWith (e: genMerge.mergeDefs e.loc e.type e.defs);
        threaded =
          ev:
          foldWith (
            e:
            genMerge.mergeDefs e.loc (
              e.type // { mergeDefs = e.type.mergeDefs.threaded (ev // { position = ev.position ++ e.step; }); }
            ) e.defs
          );
      };
    };
  cfg = modules: (genMerge.evalModuleTree { } modules).config.o;
in
{
  construct = [ "container-of-trees-below-a-step-under-any-over-approximating-container-serves" ];
  check = asserts (
    # `bar`'s key set reads the tree read at `foo`
    (cfg [
      { options.o = genMerge.mkOption { type = stepRoot (t.attrsOf sub); }; }
      (
        { config, ... }:
        {
          config.o = {
            foo.k.x = 1;
            bar = if config.o.foo.k.x == 1 then { k.x = 2; } else { };
          };
        }
      )
    ]).foo.k.x == 1
    &&
      cfg [
        {
          options.o = genMerge.mkOption {
            type = lib.types.uniq (
              lib.types.attrsWith {
                lazy = true;
                placeholder = "p";
                elemType = t.attrsOf sub;
              }
            );
          };
        }
        {
          config.o = {
            foo.k.x = 1;
            bar.k.x = 2;
          };
        }
      ] == {
        foo.k.x = 1;
        bar.k.x = 2;
      }
  );
}

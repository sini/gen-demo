# `delivery-declared-membership` — den-hoag-ien5k T3. Per variant, every node's toplevel `drvPath` through the plain
# registry (the hub's syntactic membership read) equals the same node's through the same declaration read by the
# module system (an opaque `extraModules` member, the reference). The control: `kindcfg` and `kinddefault` deliver
# `warp` and `weft` against `weft` alone, so their drvPaths differ from `none`'s where membership moved (`kindcfg`)
# and equal them where the node's own definition outranks the kind's `mkDefault` (`kinddefault`), and an equality
# that ignored membership would not read these.
{ asserts, declaredMembership }:
let
  dm = declaredMembership;
  nodes = [
    "bobbin-a"
    "bobbin-b"
  ];
in
{
  construct = [ "delivery-declared-membership" ];
  check = asserts (
    builtins.all
      (v: builtins.attrNames dm.${v}.declared == nodes && dm.${v}.declared == dm.${v}.reference)
      [
        "none"
        "kindcfg"
        "kinddefault"
      ]
    && builtins.all (n: dm.kindcfg.declared.${n} != dm.none.declared.${n}) nodes
    && dm.kinddefault.declared == dm.none.declared
  );
}

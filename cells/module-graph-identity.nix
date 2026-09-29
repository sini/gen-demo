# `module-graph-identity` — C95, den-hoag-470xp. Module imports are graph edges and a module is a
# node, identified by nixpkgs' key rule: two modules keyed `heddle` are one node, so `threads` reads
# `[ "twill" ]`, and `reed.nix` imported by two modules is one node with two import edges into it, so
# it reads `[ "reed" ]`. Both used to contribute twice. An anonymous module imported by two parents
# stays two nodes, `[ "sley" "sley" ]`, the control. The path cycle `warp.nix` ⇄ `weft.nix` closes
# over its two nodes and reads `[ "weft" "warp" ]`, where it used to overflow the stack (nixpkgs
# overflows too: a named byte-mode boundary).
{
  asserts,
  genMerge,
}:
let
  threads =
    modules:
    (genMerge.evalModuleTree {
      modules = [
        {
          options.threads = genMerge.mkOption {
            type = genMerge.types.listOf genMerge.types.str;
            default = [ ];
          };
        }
      ]
      ++ modules;
    }).config.threads;
  reed = ../fixtures/module-graph-identity/reed.nix;
  sley = {
    threads = [ "sley" ];
  };
in
{
  construct = [ "C95" ];
  check = asserts (
    threads [
      {
        key = "heddle";
        threads = [ "twill" ];
      }
      {
        key = "heddle";
        threads = [ "twill" ];
      }
    ] == [ "twill" ]
    &&
      threads [
        { imports = [ reed ]; }
        { imports = [ reed ]; }
      ] == [ "reed" ]
    &&
      threads [
        { imports = [ sley ]; }
        { imports = [ sley ]; }
      ] == [
        "sley"
        "sley"
      ]
    &&
      threads [ ../fixtures/module-graph-identity/warp.nix ] == [
        "weft"
        "warp"
      ]
  );
}

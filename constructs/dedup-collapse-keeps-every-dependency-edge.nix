# C63 -- a dedup collapse keeps every dependency edge. `pkgs.hello.drvPath` names the derivation
# with all its outputs; `unsafeDiscardOutputDependency` of it names the same `.drv` file alone.
# The two strings are EQUAL -- Nix `==` ignores context -- and carry DIFFERENT contexts, so
# `byDatum` collapses them into one, and the kept datum carries the union of the two contexts
# (den-hoag-kunjm, the quotient rule), as Nix's own concatenation would.
{
  collisionDedupOn,
  pkgs,
}:
let
  drvOnly = builtins.unsafeDiscardOutputDependency pkgs.hello.drvPath;
  drvAll = pkgs.hello.drvPath;
  collisionStorePath = collisionDedupOn [
    {
      scope = "grosgrain";
      relation = "gimp";
      datum = drvOnly;
    }
    {
      scope = "faille";
      relation = "gimp";
      datum = drvAll;
    }
  ];
in
{
  inherit drvOnly drvAll collisionStorePath;
}

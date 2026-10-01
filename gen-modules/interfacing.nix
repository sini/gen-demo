# C113's split aspect (den-hoag-5q36i). `corpus.nix` defines `interfacing` as an attrset that
# includes `selvage`; this file defines it a second time, as a `{ config, ... }:` module function,
# in a module of its own. gen-aspects coerces the function part into inline content, and delivery
# follows it like any include, so a node listing `interfacing` receives both parts.
{ ... }:
{
  config.aspects.interfacing =
    { config, ... }:
    {
      nixos.environment.etc."gen-demo/interfacing".text = "interfacing";
    };
}

# `renamedOptions` — nixpkgs-renamed-option-module-composes, den-hoag-9oc7y. Each option is defined
# through its alias and reads the value; the rename warns as nixpkgs warns, and the alias does not.
# Red: the declaration guard refuses the alias leaf by name (`a module read `options' while its own
# declarations were being folded`), which reds the whole check evaluation.
{ asserts, renamedOptions }:
{
  construct = [ "nixpkgs-renamed-option-module-composes" ];
  check = asserts (
    renamedOptions == {
      braid = "soutache";
      loops = 3;
      warnings = [ "The option `plait' defined in `tassel.nix' has been renamed to `braid'." ];
    }
  );
}

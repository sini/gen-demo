{
  title = "a module reads the module argument `specialArgs` as nixpkgs does";
  adr = "0039 parity-defect rule (1), b01wy";
  what = "`module-reads-its-specialargs`: a loom's module reads `specialArgs` as a formal while folding values and while choosing its `imports`, and from the whole argument set (`args@{ ... }`); a planted `_module.args.specialArgs` does not reach it, a caller's own `specialArgs.specialArgs` does, and a gen `submodule` child reads its own type's arguments, each equal to nixpkgs' own `lib.evalModules` over the same loom, where gen-merge refused the formal by name and aborted on the argument set's read";
}

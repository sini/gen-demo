{
  title = "an evaluation publishes its extension unread, as nixpkgs does";
  adr = "0033, 0039";
  what = "`an-extension-naming-its-module-argument-is-published-unread`: an option typed by `(extendModules { modules = [ ext ]; }).type` publishes its module set as nixpkgs' `lib.evalModules` does, reading nothing of `ext`: an extension equal to the name placeholder in every pair but its `name`, which the top level never defines, publishes two modules, as does home-manager's `specialisation` shape (`mkOverride 0 { }` beside `_module.args.name = mkForce name`), and a user module equal to the placeholder is published as the user's module, last (`FP`). gen-merge decided which module was its own name placeholder by comparing the last module with `==`, which forced the extension's `name` and refused \"module argument `name' is not defined\", and took the look-alike for its own placeholder, publishing `PF`";
}

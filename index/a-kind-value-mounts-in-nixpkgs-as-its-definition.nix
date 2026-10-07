{
  title = "a kind value mounts in nixpkgs as its definition";
  adr = "0039 (serve half), 0025 item 1, r05lc, e5whp";
  what = "`kind-value-mounts-in-nixpkgs`: a gen-schema kind value (an attrset entry carrying options, one importing a module, a function entry under an open freeform, and a kind composing a parent) and a gen-aspects aspect kind (an attrset entry and a function entry), each mounted in a nixpkgs `lib.evalModules` submodule, read what the same definitions mounted raw read: gen-merge's `__reservedKeys` and `__keyEq` ride on a functor module's record, which nixpkgs never collects, where nixpkgs refused them as unsupported attributes or a freeform gained a stray `__reservedKeys` key";
}

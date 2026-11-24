{
  title = "an instance evaluation retained by its caller";
  adr = "0039";
  what = "gen-schema's `evalInstance { } type loc defs` returns `{ config; provenance; }` of the one evaluation the instance type's exported `merge` makes over the definitions: `config` is the typed value, `provenance` is the same evaluation's, and a copy of the type whose `merge` is not its own fold is refused by name";
}

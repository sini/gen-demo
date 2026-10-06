{
  title = "the schema option redeclared, one construction";
  adr = "0034, 0025 item 1";
  what = "`schema-option-redeclaration`: `mkSchemaOption { }` declared twice, one value or two calls, reads `selvage` through both declarations; two declarations differing in `strict` are refused catchably in both orders, and so are two whose facet option is typed by two constructions of one check-only `mkOptionType`, while one facet value shared by both merges";
}

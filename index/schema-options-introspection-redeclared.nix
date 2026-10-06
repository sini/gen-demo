{
  title = "the schema option's introspection, redeclared";
  adr = "0034, 0012, 0025 item 1";
  what = "`schema-option-redeclared-reads-its-kinds`: one `mkSchemaOption { }` value declared by two modules reads `_kindNames` as `[ \"bobbin\" \"selvage\" ]`, and its `_kindNames`, `_topology` and `_edges` equal the option declared once; before, the introspection module was imported twice and `_kindNames` refused \"read-only, but it is defined 2 times\"";
}

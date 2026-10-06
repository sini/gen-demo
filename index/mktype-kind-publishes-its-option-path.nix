{
  title = "a `mkType` kind publishes its option path";
  adr = "0025";
  what = "`mktype-kind-publishes-option-path`: a `selvage` declared through `mkSchemaOption { mkType }` whose result omits `kind` reads `.kind` = `\"selvage\"` and `mkInstanceType` admits it, where `.kind` aborted uncatchably; a result echoing `\"bobbin\"` still reads `\"selvage\"`; a correct echo is the control";
}

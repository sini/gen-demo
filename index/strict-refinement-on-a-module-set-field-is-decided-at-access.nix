{
  title = "strict refinement on a module-set field is decided at access";
  adr = "0025 item 1";
  what = "`flounceModuleSetAccess`: a strict refinement on a field whose type carries a module set at any carried depth is checked when the field is read, so the registry knot under a strict `refined` composes and a failing refinement refuses that field's read while a sibling serves; a failing strict refinement on a flat field is still decided at construction, refusing the sibling too";
}

{
  title = "a delivery class's members read from what each node declares";
  adr = "0028, 0039, ien5k";
  what = "`delivery-declared-membership`: a plain gen-schema registry named by `gen.nodeRegistryPath`, its kind declaring nothing for `aspects`, setting it, or setting it under `mkDefault`, delivers every node's toplevel at the drvPath the module-system read delivers (the same declaration with an opaque `extraModules` member); the hub reads each node's membership with gen-schema's `declaredField`, which serves where the node's declarations decide it alone (no kind definition, or the kind's `mkDefault` outranked) and falls back to the module read where two definitions survive at one priority";
}

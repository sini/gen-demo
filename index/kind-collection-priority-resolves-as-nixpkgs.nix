{
  title = "a kind's collection resolves its definitions' priorities as nixpkgs does";
  adr = "0029";
  what = "a `user` kind's `classes` collection defined only by `mkDefault`, and an `admin` kind's `classes` (a plain definition over `mkDefault` and `mkIf false`) and `metadata` (a plain definition under `mkForce`); the module system resolves each definition's priority before the collection folds, so the values are the ones nixpkgs serves for the same definitions of an option";
}

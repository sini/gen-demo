{
  title = "a module's `options` argument answers nixpkgs' evaluated keys";
  adr = "0025 item 1, 0039, den-hoag-ixcxl";
  what = "`options-argument-evaluated-record`: a module reading `options.warp.isDefined` (under `mkIf`) and `options.warp.definitions` gets nixpkgs' answers, `[ \"warp\" ]` and `[ [ \"w\" ] ]`, where gen-merge's argument lacked both keys and the read aborted uncatchably; the published record's `definitions` agrees, and an option nobody defines reads `isDefined = false` on both engines, the control";
}

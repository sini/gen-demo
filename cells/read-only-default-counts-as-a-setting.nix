# `read-only-default-counts-as-a-setting` -- den-hoag-1gv6r. A `readOnly` option's declared default is a
# setting, as nixpkgs' `evalOptionValue` counts `defs'`: one definition beside it is refused, at a leaf
# and at a `submodule` option alike. The default alone and a lone definition with no default are the
# served twins, so a fold refusing every readOnly option cannot pass; two definitions are refused.
{
  asserts,
  genMerge,
}:
let
  T = genMerge.types;
  read =
    extra: defs:
    (genMerge.evalModuleTree { } (
      [
        {
          options.spool = genMerge.mkOption (
            {
              type = T.int;
              readOnly = true;
            }
            // extra
          );
        }
      ]
      ++ map (v: { spool = v; }) defs
    )).config.spool;
  refused = v: !(builtins.tryEval (builtins.deepSeq v null)).success;
  nested =
    (genMerge.evalModuleTree { } [
      {
        options.reel = genMerge.mkOption {
          type = T.submodule { options.l = genMerge.mkOption { type = T.listOf T.int; }; };
          default.l = [ 1 ];
          readOnly = true;
        };
      }
      { reel = genMerge.mkDefault { l = [ 9 ]; }; }
    ]).config.reel;
in
{
  construct = [ "a-read-only-options-default-counts-as-a-setting" ];
  check = asserts (
    refused (read { default = 1; } [ 2 ])
    && refused nested
    && read { default = 1; } [ ] == 1
    && read { } [ 2 ] == 2
    && refused (
      read { } [
        2
        3
      ]
    )
  );
}

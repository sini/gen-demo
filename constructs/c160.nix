# ── C160 — a Merge Strategy serves the value its warning describes (den-hoag-34i06). One binding,
# `spool = "cotton"`, under a caller's Merge Strategy, wrapped over a module reading `spool`; nixpkgs'
# own `lib.evalModules` supplies `spool = "linen"` through `config._module.args`. `shape` is the
# module's: `partial` leaves `config` unbound, `full` binds every formal.
{ genBind, lib }:
{
  spoolUnderStrategy =
    shape: policy:
    (lib.evalModules {
      modules =
        (genBind.wrapAll
          {
            bindings.spool = "cotton";
            mergeStrategies.spool = policy;
          }
          [
            (
              if shape == "full" then
                { spool }: { config.out = spool; }
              else
                { spool, config, ... }: { config.out = spool; }
            )
            {
              options.out = lib.mkOption { type = lib.types.str; };
              options.warnings = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
              };
              config._module.args.spool = "linen";
            }
          ]
        ).all;
    }).config;
}

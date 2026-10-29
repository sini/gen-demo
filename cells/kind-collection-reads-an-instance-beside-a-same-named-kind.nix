# `kind-collection-reads-an-instance-beside-a-same-named-kind` — den-hoag-same-name-self-read-residue-d65ta. `host`'s
# collection `excludes` reads an instance of `host` itself, and `host`'s registry also reaches another tree's kind
# named `host` (a different declaration). Kinds meet only at one declaration node, so the two never meet, no mark is
# read at the import, and the instance reads its own address. Before, the two same-named kinds met by name, the
# meeting forced the mark, and the read recursed (an uncatchable abort). The renamed control (`box`) always read it.
{
  asserts,
  genMerge,
  genSchema,
}:
let
  T = genMerge.types;
  otherOf =
    name:
    (genMerge.evalModuleTree { } [
      (
        { config, ... }:
        {
          options.schema = genSchema.mkSchemaOption { collections.excludes.default = [ ]; };
          config.schema.oconf = { };
          config.schema.${name} = {
            inherits = [ config.schema.oconf ];
            options.port = genMerge.mkOption {
              type = T.int;
              default = 22;
            };
          };
        }
      )
    ]).config.schema.${name};
  addrBeside =
    name:
    (genMerge.evalModuleTree { } [
      (
        { config, ... }:
        {
          options.schema = genSchema.mkSchemaOption {
            collections.excludes = {
              default = [ ];
              merge = acc: v: acc ++ v;
            };
          };
          options.hosts = genSchema.mkInstanceRegistry {
            extraModules = [ (otherOf name) ];
          } config.schema.host;
          options.aspects = genMerge.mkOption { type = T.attrsOf T.anything; };
          config.schema.conf = { };
          config.schema.host = {
            inherits = [ config.schema.conf ];
            options.addr = genMerge.mkOption { type = T.str; };
            excludes = [ config.aspects.unwanted ];
          };
          config.hosts.igloo.addr = "10.0.1.1";
          config.aspects.unwanted.domain = config.hosts.igloo.addr;
        }
      )
    ]).config.hosts.igloo;
in
{
  construct = [ "kind-collection-reads-an-instance-beside-a-same-named-kind" ];
  check = asserts (
    (addrBeside "host").addr == "10.0.1.1"
    && (addrBeside "host").port == 22
    && (addrBeside "box").addr == "10.0.1.1"
  );
}

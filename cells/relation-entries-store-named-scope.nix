# `relation-entries-store-named-scope` — C45, den-hoag-3tsd3. gen-view keys a caller's identifiers
# by their text, so a scope named `baseNameOf pkgs.hello`, which carries string context, files its
# datum and reads it back: `relationEntries` answers one entry whose scope and datum both keep their
# context, where the read used to abort with `… is not allowed to refer to a store path`. It is a
# non-walking read; a view over store-named scopes still aborts in gen-graph (den-hoag-u9k7j).
#
# C45 -- den-hoag-3tsd3. Live control: movement-dedup-equality.
{ asserts, storeNamedEntries }:
{
  construct = [ "C45" ];
  check = asserts (
    builtins.length storeNamedEntries == 1
    && builtins.hasContext (builtins.head storeNamedEntries).scope
    && builtins.hasContext (builtins.toJSON (builtins.head storeNamedEntries).datum)
  );
}

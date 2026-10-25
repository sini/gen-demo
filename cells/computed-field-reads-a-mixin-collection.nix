# `computed-field-reads-a-mixin-collection`. A computed field reads the collection the kind
# publishes, a mixin's contribution included: `host`'s `tagged` is `[ "web" "monitored" ]`, equal to
# its published `tags` and to the kind-written twin's `tagged`. Red when the hook reads the kind's own
# definitions only (`tagged` `[ "web" ]` beside `tags` `[ "web" "monitored" ]`).

{
  asserts,
  hostByMixinTags,
  hostByKindTags,
}:

{
  construct = [ "computed-field-reads-a-mixin-collection" ];
  check = asserts (
    hostByMixinTags.host.tagged == [
      "web"
      "monitored"
    ]
    && hostByMixinTags.host.tagged == hostByMixinTags.host.tags
    && hostByMixinTags.host.tagged == hostByKindTags.host.tagged
  );
}

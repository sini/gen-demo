{
  title = "a scope named after a package";
  adr = "0025 item 1";
  what = "`relation-entries-store-named-scope`: a scope named `baseNameOf pkgs.hello` carries string context; gen-view keys it by its text, so the datum filed there is read back as one entry whose scope and datum keep their context, where the read used to abort (`… is not allowed to refer to a store path`)";
}

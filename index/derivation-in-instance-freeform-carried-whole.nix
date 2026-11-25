{
  title = "a derivation in an instance freeform is carried whole";
  adr = "0039";
  what = "`derivation-in-instance-freeform-carried-whole`: a non-strict gen-schema instance's freeform (`attrsOf anything`) serves `pkgs.hello` defined once whole (`removeAttrs [ \"type\" ]` equal, same `drvPath`), refuses it defined twice, and reads the names of a derivation whose `outPath` throws without forcing it, as nixpkgs' `stringCoercibleSet` does";
}

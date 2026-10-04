# `mktype-kind-publishes-option-path` — C68, den-hoag-3x3bi (ADR-0025). A kind declared through
# `mkSchemaOption { mkType = … }` publishes its OPTION-PATH NAME as `.kind`, whatever the `mkType`
# result carries under that key. A `selvage` whose result omits `kind` reads `"selvage"`, and
# `mkInstanceType` admits it; a `selvage` whose result echoes `"bobbin"` still reads `"selvage"`.
# Before gen-schema ba34a93 the `mkType` arm never wrote `kind`: the omitting kind's `.kind` aborted
# uncatchably (`attribute 'kind' missing`), and the echoing kind published the echo.
#
# Admission is read through a USE of the type: an instance of it in an evaluation reads its field.
# A `deepSeq` of the type record is not an admission test, and since den-hoag-n6dh7 Unit 2.4 it
# reaches a submodule's called `whenEmpty.value`, which refuses by name (item 1; OQ2 α). gen-schema's
# `mktype-kind-value` admission cell took the same re-pin (Unit 2 landing gate, C2).
{
  asserts,
  genMerge,
  inputs,
}:
let
  schema = inputs.gen.lib.substrate.schema;
  spool = genMerge.mkOption {
    type = genMerge.types.str;
    default = "linen";
  };
  resultWith = extra: { __functor = _: _: { options.spool = spool; }; } // extra;
  selvageBy =
    mkType:
    (genMerge.evalModuleTree { } [
      { options.schema = schema.mkSchemaOption { inherit mkType; }; }
      { config.schema.selvage = { }; }
    ]).config.schema.selvage;
  omits = selvageBy ({ ... }: resultWith { });
  echoesWrong = selvageBy ({ ... }: resultWith { kind = "bobbin"; });
  echoesRight = selvageBy ({ kind, ... }: resultWith { inherit kind; });
in
{
  construct = [ "C68" ];
  check = asserts (
    # the omitting arm publishes the option path, and the instance type admits it
    omits.kind == "selvage"
    && (builtins.tryEval (
      builtins.deepSeq
        (genMerge.evalModuleTree { } [
          {
            options.h = genMerge.mkOption { type = schema.mkInstanceType omits { }; };
            config.h = { };
          }
        ]).config.h.spool
        true
    )).success
    # a wrong echo does not win over the option path
    && echoesWrong.kind == "selvage"
    # control: a correct echo reads the same
    && echoesRight.kind == "selvage"
  );
}

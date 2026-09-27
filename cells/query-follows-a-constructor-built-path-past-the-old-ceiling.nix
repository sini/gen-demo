# `query-follows-a-constructor-built-path-past-the-old-ceiling` — C2,
# den-hoag-regex-statekey-ceiling-4ok8y and den-hoag-smn53. Two follows built with gen-graph's regex
# constructors, 5,000 levels folded strictly, each meaning one or more `tacks`. `tail` nests at the
# tail, `tacks (…)*`: forcing its key used to walk the whole term and meet the evaluator's call-depth
# ceiling near 2,500 levels. `head` nests at the head, `(…)* tacks`, where the derivative descends:
# deriving it used to abort near 417 levels. Both aborts are ones `tryEval` cannot catch. Each
# node's key and nullability are now forced when the node is built, and a tall term's derivative
# is memoised bottom-up, so the query answers. Two more follows share their subterms, which the
# derivative used to walk once per path (den-hoag-naalo): `shared` parses `tacks` then thirty nested
# `(…?)+` around `tacks?`, where `plus` holds its argument twice at every level, and `fan` folds a
# 64-way alternation four levels deep by the constructors, each branch holding the level below.
# Both mean one or more `tacks` on this graph, and both used to not return. A term that unfolds past
# 1,024 nodes is now derived through the memo, so each distinct subterm is stepped once. Plain
# `plus (lit "tacks")` is the control: the same language, one level deep.
{ asserts, genGraph }:
{
  construct = [ "C2" ];
  check = asserts (
    let
      r = genGraph.regex;
      # thimble → awl → twill → spool, every edge labeled `tacks`
      next = {
        thimble = [ "awl" ];
        awl = [ "twill" ];
        twill = [ "spool" ];
        spool = [ ];
      };
      lg = genGraph.labeledFrom {
        nodes = builtins.attrNames next;
        perLabel.tacks = id: next.${id};
      };
      walk =
        follow:
        genGraph.query {
          graph = lg;
          from = "thimble";
          inherit follow;
        };
      nest =
        step: walk (builtins.foldl' (acc: _: step acc) (r.lit "tacks") (builtins.genList (i: i) 5000));
      tail = nest (
        acc:
        r.seq [
          (r.lit "tacks")
          (r.star acc)
        ]
      );
      head = nest (
        acc:
        r.seq [
          (r.star acc)
          (r.lit "tacks")
        ]
      );
      rep = n: c: builtins.concatStringsSep "" (builtins.genList (_: c) n);
      shared = walk (r.parse ("tacks" + rep 30 "(" + "tacks?" + rep 30 ")+"));
      fan = walk (
        builtins.foldl' (
          x: _:
          r.alt (
            builtins.genList (
              i:
              r.seq [
                (r.star x)
                (r.lit (if i == 0 then "tacks" else "l${toString i}"))
              ]
            ) 64
          )
        ) (r.lit "tacks") (builtins.genList (i: i) 4)
      );
      shallow = walk (r.plus (r.lit "tacks"));
    in
    tail == shallow
    && head == shallow
    && shared == shallow
    && fan == shallow
    &&
      shallow == [
        "awl"
        "spool"
        "twill"
      ]
  );
}

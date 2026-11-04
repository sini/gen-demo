{
  title = "fan-out warm evaluations read their prior's identity map";
  adr = "0008, 0034, 0032";
  what = "warm evaluations started from one prior over minted instances read the prior's own identity map (`warmDecision.priorIdentities`, its identities by path, walked once over its own tree); a sibling whose edit moves no identity is served warm and equals cold, and the one whose edit moves an identity is refused without the refusal reaching the siblings started from the same prior";
}

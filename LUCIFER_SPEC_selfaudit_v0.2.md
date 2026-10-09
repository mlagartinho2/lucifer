# Self-Audit — Internal Consistency Check on `LUCIFER_SPEC_v0_draft.md` (v0.2)

Findings only, nothing applied yet — same ground rule as the original self-audit
request. Two kinds of problem turned up: a handful of **design-level inconsistencies**
(sections making claims that don't actually hold up against each other) and a large
cluster of **broken or mismatched `§N` cross-references** (mechanical, but pervasive
enough to be worth fixing as a batch). Design findings first, since they're the ones
that actually affect behavior.

---

## A. Design-level findings

### A1. `INFRA` failures feed the same escalate/abort budget as `SELF_CORRECTABLE` ones — escalation can trigger for a reason a stronger model can't fix

§5.1's taxonomy table states `INFRA` "still counts toward tool-kind budget" (same
budget as `SELF_CORRECTABLE`). §3.2 defines only two kinds — tool and verification —
with one shared escalate/abort threshold pair per kind, and explicitly says an
escalate-threshold breach "hands control to the Model Router... to swap to a stronger
model." Put together: three consecutive sandbox timeouts or gateway errors — pure
infrastructure flakiness, nothing to do with model quality — would trip the exact same
escalate-threshold that a model's repeated reasoning mistakes would, and trigger the
exact same response: swapping to a stronger, presumably more expensive model. A
stronger model can't fix a flaky sandbox. That's not just imprecise, it's a real
design gap — escalation exists to solve "the model isn't capable enough," and this
lets it fire for "the infrastructure had a bad five minutes," burning cost without
addressing the actual problem. Worth deciding whether `INFRA` should feed its own
separate counter (surfaced to an operator, the way `SANDBOX_ERROR`/telemetry-style
signals are described elsewhere in the doc) rather than sharing the tool-kind budget
that drives model escalation. The abort side of this is less clearly wrong — enough
infra flakiness pausing a trajectory for a human to look is arguably fine — but the
escalate side doesn't make sense as specified.

### A2. §5.1's new B1 resolution leans on a sandbox-isolation mechanism the spec never actually specifies

The `PATH_OUTSIDE_REPO`/`COMMAND_NOT_ALLOWLISTED` → `SELF_CORRECTABLE` resolution just
added to §5.1 argues that "`run_command`'s sandbox mount means even a successful
escape only reaches a disposable copy (§7.3)." But §7.3 only describes *sync*
mechanics (copying Workspace's staged content into a sandbox directory) and *change
detection* (hashing to find what a command modified) — it never actually states that
the sandboxed process is filesystem-isolated (chroot, container, restricted mount,
or similar) from the rest of the host. As written, "sandbox" could just mean "a
directory holding a copy of the repo," which is data isolation, not filesystem-access
isolation — a process running there with no further restriction could, in principle,
still read or write paths outside that directory if nothing else stops it. The B1
resolution's argument depends on an isolation guarantee that §6.2/§7.3 don't commit
to. Either §6.2 (or §7.3) needs an explicit line establishing what actually contains
the sandboxed process — even one sentence, e.g. "the sandboxed process's only writable
mount is the sandbox directory itself" — or the B1 argument in §5.1 needs to stop
citing it as a given. Worth noting: this is exactly the kind of mount-level detail the
prior draft (v0.11) had and this spec's cross-check (§A3) already flagged as missing —
it just became load-bearing for a specific decision now, which raises its priority
from "nice detail to have" to "the argument in §5.1 doesn't actually hold without it."

### A3. §5.1's new B1 resolution cites §4.1 for a claim §4.1 doesn't make

Same paragraph argues that categorizing these errors `UNSAFE` "undercuts the
'escalation is the safety net, not the classifier' logic behind triage in the first
place (§4.1)." §4.1's actual text just says triage and escalation are separate
mechanisms with separate triggers — it never states this "safety net, not classifier"
framing, or the underlying idea that a fast/cheap tier is a legitimate first attempt
specifically because escalation exists to catch its failures. The citation implies
§4.1 already establishes something it doesn't. Either fold that framing into §4.1 as
an explicit design rationale (it's a genuinely useful thing to state — it's part of
why triage doesn't need to be conservative), or drop the citation from §5.1 and let
the argument stand on its own without pointing at unsupported backup.

### A4. No shared predicate for "is this path within the repo root," unlike sensitive-path

§7.4 establishes one shared `is_sensitive_path` predicate reused everywhere a
sensitivity check is needed — a locked decision. The commit-time defense-in-depth
bullet just added to §7.6 checks two different things: the sensitive-path predicate
*and* "the repo-root boundary," but only the first has a named, shared, reused
predicate. `PATH_OUTSIDE_REPO` is referenced as an error type in multiple places
(`edit_file`/`create_file`/`run_command`/now `commit()`) without ever naming a single
shared boundary-check predicate the way `is_sensitive_path` is named and reused. Not
a locked requirement — the "one shared predicate" decision was specifically about
sensitive paths — but given the exact same "checked from multiple call sites" shape
now applies to the repo-root boundary too, it's worth applying the same pattern for
the same reason: avoiding four slightly-different reimplementations of "is this path
inside the repo."

### A5. Ambiguous whether a "stuck" event increments the tool-kind budget once or twice

§5.1's table says `SELF_CORRECTABLE` "counts toward stuck-detection *and* tool-kind
budget" — read naturally, that's one failure causing one increment, with
stuck-detection as an additional classification of that same event. §3.2's assumption
says "stuck-repeat detection... increments the tool-kind counter," phrased as if
stuck-detection is itself a separate mechanism that *also* increments the counter. If
implemented literally as two separate increment calls (one for the base
`SELF_CORRECTABLE` failure, one for it additionally being "stuck"), a single failed
mutating-tool retry would count double against the tool-kind abort threshold — reaching
the escalate/abort thresholds twice as fast as an equivalent run of non-repeated
`SELF_CORRECTABLE` failures. Worth stating explicitly which it is.

### A6. Escalate-threshold trigger semantics unspecified: exact-count or at-or-above

§3.2 doesn't say whether `tool_escalate_threshold` fires exactly once (count equals
the threshold) or re-fires every time the count is at or above it. Minor on its own —
`escalate()` is presumably idempotent/a no-op once already escalated or at the
ceiling — but worth pinning down so "does escalate get called repeatedly for one bad
stretch" isn't left to implementation guesswork.

---

## B. Broken / mismatched `§N` cross-references

24 instances, plus 2 notation nits in §13. About 20 of the 24 share the same shape —
a reference to section *N* written as *N+1* — strongly suggesting these trace back to
a point where the section numbering shifted by one (most likely: §2, "Model Registry
Shape," was split out as its own section at some point after the rest of the document
had already been drafted with the later sections numbered one lower) and the inline
prose citations were never re-walked against the final headers. But the pattern isn't
universal — a few are wrong in a way that doesn't fit that shift at all — so this
isn't safe to fix with a single mechanical "subtract 1" pass; each one needs
individual verification against what it's actually trying to point at. §11 and §12
(both apparently written last, after headers were finalized) have zero broken
references anywhere in them — worth using as the clean reference points if useful
while fixing the rest.

| Line | Written as | Should be | Context | Fits the +1 pattern? |
|---|---|---|---|---|
| 34 | `(§5)` | `§4` | triage/escalation candidate pool | Yes |
| 34 | `(§10)` | `§9` | retrieval-only models | Yes |
| 37 | `see §10` | `§9` | reranker access pattern | Yes |
| 38 | `(§11)` | `§10` | CLI editor integration | Yes |
| 54 | `(§4.2)` | `§3.2` | budget calc referencing context-window % | Yes |
| 62 | `(§12)` | `§11` | upfront planning rejected as non-goal | Yes |
| 66 | `(§6.3)` | `§5.3` and/or `§5.5` | "suspend or abort" | Yes |
| 68 | `§6.6` | `§5.6` | schema validation before dispatch | Yes |
| 69 | `§6.2` | `§5.2` | typed envelope | Yes |
| 70 | `§6` | `§5` | stuck/UNSAFE/risk-flag routing | Yes |
| 94 | `(§5.2)` | likely `§4.3` | Model Router escalation mechanism | **No** — different kind of error, verify intent |
| 94 | `(§6.3)` | `§5.3` | abort signal | Yes |
| 94 | `(§6.5)` | `§5.5` | suspend/resume mechanism | Yes |
| 123 | `# §8.6` | `§7.6` | `proceed_to_commit_flow()` | Yes |
| 126 | `(§8.2)` | `§7.2` | staged-file state | Yes |
| 203 | `§8.2` | `§7.2` | `STALE_FILE_VIEW` | Yes |
| 208 | `§7.5` | `§6.2` | `COMMAND_TIMEOUT` / process-group kill | **No** — unrelated section, not a shift |
| 254 | `(§8.5)` | `§7.5` | hold-the-round rule | Yes |
| 272 | `§10` | `§9` | `search_code` embedding+rerank | Yes |
| 281 | `(§10)` | `§9` | search/grep split rationale | Yes |
| 314 | `(§8.3)` | `§7.3` | sandbox change-detection pipeline | Yes |
| 314 | `(§8.4)` | `§7.4` | sensitive-path exclusion | Yes |
| 315 | `(§8.3)` | `§7.3` | "executes against synced sandbox copy" | Yes |
| 335 | `(§9)` | `§8` | transcript, token-budgeted | Yes |

Plus two notation issues in §13 (not mis-shifted, just malformed): item 2 writes
`§12.4` as if §12 had decimal subsections — it's a flat numbered list (1–8), so this
should read as "item 4 of §12," not a section number. Item 25 literally writes `§9
(compaction)` — the parenthetical shows the number and the label disagree with each
other; compaction is §8, not §9.

Worth flagging separately: the *same* targets get referenced correctly in some places
and incorrectly in others. §7.3/§7.4 are cited correctly from within §7.3 itself
(line 355) and throughout §11/§12, but incorrectly as `§8.3`/`§8.4` from §6.2 (lines
314–315). §5.5 (suspend/resume) is cited correctly from §6.4's `ask_user` description
(line 323) and from §6's tool table (line 278), but incorrectly as `§6.5` from §3.2
(line 94). That inconsistency — right in some spots, wrong in others, for the exact
same target — is what rules out a clean global find-and-replace as the fix; it has to
be gone through reference by reference.

---

*Nothing above has been applied to `LUCIFER_SPEC_v0_draft.md`. Let me know which of
A1–A6 you want resolved (and how), and whether to go ahead and fix the §B reference
list — the +1-pattern ones are close to mechanical, but I'd still walk each one
individually rather than batch-replace, given two of them don't fit the pattern and
the "right in one place, wrong in another" cases show this wasn't a single clean
shift.*

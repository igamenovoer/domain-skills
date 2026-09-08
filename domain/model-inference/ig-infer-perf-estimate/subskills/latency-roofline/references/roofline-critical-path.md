# Roofline and Critical-Path Reference

## 1. Define the result and its direction

Keep these products distinct:

- **physical lower bound on latency**: uses hardware peaks and complete work;
- **calibrated analytical center**: uses workload-representative sustained rates;
- **simulated service time**: combines profiles and a declared schedule;
- **measured latency**: comes from the target runtime and workload; and
- **throughput upper bound**: obtained by inverting a valid latency/resource bound.

A lower bound can be useful without being predictive. Label it in the result and keep
it beside any calibrated center.

Define the phase precisely:

- Prefill consumes a prompt, creates persistent state, and may use chunked scheduling.
- A decode round consumes the current batch and emits one or more tokens per request.
- MTP/speculative decoding adds draft and target-verification phases.
- Queueing delay belongs to the serving-scheduling model, not an operator roofline.

For homogeneous one-token decode, `TPOT` is the wall time between successive committed
tokens for one request. Aggregate throughput and per-user throughput require the same
round-time denominator; do not infer either from a per-layer kernel in isolation.

## 2. Operator and event ownership

Create one row per event with these fields:

```text
event,phase,model_layers,stage,rank,node,batch,positions,flops,macs,
read_bytes,write_bytes,stored_weight_bytes,converted_values,messages,launches,
predecessors,resource,can_overlap,source,evidence_class,owner
```

Inventory at least:

- embedding, normalization, dense projections, and LM head;
- routed and shared experts, gates, dispatch, combine, and expert communication;
- native attention score, softmax/top-k, value accumulation, and index scoring;
- recurrent/linear-attention state reads, writes, and contractions;
- sparse/offloaded-cache selection, key reconstruction, value fetch, and attention;
- weight and cache dequantization/unpacking;
- TP/EP/DCP collectives and PP transfers;
- sampling, scheduler, graph replay, and framework launch gaps.

If a framework or upstream profile already includes an event, an external adapter must
not add it again. Record the boundary explicitly, such as “profile contains projections,
experts, LM head, and TP collectives; attention and offload are external.”

## 3. Per-event rooflines

For event \(j\), let \(F_j\) be FLOPs, \(B_j\) bytes moved through the relevant memory,
\(Q_j\) converted scalar values, \(P_{\max}\) peak FLOP/s, \(BW_{\max}\) peak or stream
bandwidth, and \(D_{\max}\) conversion values/s. With kernel-specific efficiencies,

\[
P_{\mathrm{eff},j}=\eta_{C,j}P_{\max},
\qquad
BW_{\mathrm{eff},j}=\eta_{B,j}BW_{\max}.
\]

For one fused kernel whose operations genuinely overlap,

\[
t_j=\max\left(
\frac{F_j}{P_{\mathrm{eff},j}},
\frac{B_j}{BW_{\mathrm{eff},j}},
\frac{Q_j}{D_{\mathrm{eff},j}},
t_{\mathrm{launch},j}
\right).
\]

If conversion, copy, and compute are separate kernels, encode them as separate events
and sum or overlap them according to their dependencies. Do not append conversion to a
memory time that was measured by a fused conversion kernel unless the benchmark scope
proves it is missing.

Arithmetic intensity is

\[
I_j=\frac{F_j}{B_j}\quad\text{FLOP/byte}.
\]

The balance point is

\[
I^*=\frac{P_{\mathrm{eff},j}}{BW_{\mathrm{eff},j}}.
\]

An event is compute-bound under this two-roof model when (I_j>I^*), otherwise
memory-bound. Conversion and communication can introduce additional controlling roofs.

Count units exactly. Many libraries report MACs and later multiply by two to obtain
FLOPs. Convert decimal GB/s and binary GiB/s through bytes rather than changing labels.
Do not multiply a stream-bandwidth measurement by an MBU that was defined relative to
nameplate; use one consistent basis, for example

\[
BW_{\mathrm{eff}}=BW_{\mathrm{nameplate}}\times\mathrm{MBU}
\]

or

\[
BW_{\mathrm{eff}}=BW_{\mathrm{stream}}\times\eta_{\mathrm{kernel}},
\]

but not both discounts unless their definitions justify it.

## 4. Choosing efficiency inputs

Use workload-representative measured rates whenever possible. Record batch, matrix
shape, dtype, fusion, software version, clock/power state, and working-set size. A
GEMM efficiency measured at one shape is not an attention, sparse-gather, or MoE-grouped
GEMM efficiency.

When no target measurement exists:

1. calculate the physical peak bound;
2. select a same-architecture proxy or published phase-specific range;
3. label the central value `proxy-measured` or `literature-prior`;
4. sweep the range and preserve the bound; and
5. identify whether the result is decision-sensitive to that input.

Do not choose an efficiency by reverse-fitting a desired community result. Community
benchmarks become validation anchors only after normalizing model revision, context,
batch, quantization, hardware, total/per-user/per-GPU rate, and prefill versus decode.

Hardware primitives can be calibrated without model weights: streaming HBM, pinned
H2D, simultaneous H2D, P2P, conversion, and synthetic representative GEMMs. End-to-end
fusion, routing, framework gaps, and quality require the actual runtime or faithful
operator implementations.

## 5. Model-core work

For dense active parameters (A), a first-order token/batch arithmetic count is

\[
F_{\mathrm{linear}}\approx2AC,
\]

where (C) is the number of token positions processed together. This does not imply
that all stored weights are read independently for every sequence; shared weights may
be reused across the batch.

For a uniform MoE center with (E) routed experts, (k) selections per token, and
(C) sequences, the expected number of distinct experts touched is

\[
E_{\mathrm{active}}(C)
=E\left[1-\left(1-\frac1E\right)^{kC}\right].
\]

Use \(kC\) for routed-expert arithmetic and \(E_{\mathrm{active}}\) for expected expert
weight traffic. Add balanced, measured, and skewed-routing cases; the occupancy formula
is not proof of an actual routing distribution. Include dispatch/combine and expert
communication where the placement requires them.

## 6. Attention and recurrent-state events

For an attention layer reading (n_a) historical rows, (H_q) local/global query
heads as appropriate, Q/K score width (d_q), value width (d_v), and batch (C), a
first-order score-plus-accumulation count is

\[
F_{\mathrm{attn}}\approx2Cn_aH_q(d_q+d_v).
\]

Derive (H_q)'s TP factor from the actual kernel. Cache read bytes need not have the
same sharding as query-head arithmetic; a replicated MLA latent can feed TP-sharded
query heads.

For native sparse attention, index scoring and selected main attention are usually
causally sequential:

\[
t_{\mathrm{native-attn}}=t_{\mathrm{index}}+t_{\mathrm{selected-main}}.
\]

Each term can have its own compute, HBM, conversion, and launch roof. Model stored rows
and attended rows separately.

For recurrent state of (S) bytes per sequence, at least one read and write gives

\[
t_{\mathrm{state,mem}}\ge\frac{2CS}{BW_{\mathrm{eff}}}.
\]

Add contraction/update FLOPs as another roof. A fused multi-position verification may
read/write persistent state once while arithmetic scales with positions; an unfused
implementation may touch it repeatedly. Keep both as explicit alternatives.

## 7. Sparse cache offload and prediction

For selected fraction \(\alpha\) and context \(N\), use

\[
S(N)=\lceil\alpha N\rceil.
\]

Do not equate this accessed set with HBM or host storage. For a fetch-at-decode
ShadowKV-like dependency, the per-layer critical order is

\[
t_l=t_{\mathrm{select}}
+\max(t_{K\text{-reconstruct}},t_{V\text{-fetch}})
+t_{\mathrm{sparse-attn}}.
\]

Selection, materialization, and attention are separate events. A paper table with
separate columns must not be collapsed into one and then charged again.

Let (r) be exact selected entries retained from the previous token. On the remaining
(1-r) true misses, predictor recall (R) and precision (P) imply

\[
f_{\mathrm{prefetch}}=(1-r)\frac{R}{P},
\qquad
f_{\mathrm{JIT}}=(1-r)(1-R).
\]

The prefetched term includes false positives; the JIT term contains false negatives.
State whether recall and precision are measured over all selected rows or only the
post-reuse miss set.

A token-ahead predictor may move \(f_{\mathrm{prefetch}}\) off the current token's
causal path, but it does not remove its DMA, PCIe, host-DRAM, HBM-ingress, or buffer
demand. Across request groups (g), impose a background service roof such as

\[
T_{\mathrm{background}}
=g\,t_{\mathrm{prefetch,node}},
\qquad
T_{\mathrm{round}}
=\max(T_{\mathrm{critical}},T_{\mathrm{background}}).
\]

Also retain selection verification unless the predictor is defined as authoritative.
An authoritative perfect oracle that skips selection is an explicit upper-bound case,
not an ordinary 100%-recall sensitivity point.

Layer-ahead and token-ahead prefetch are different. Record the event that makes the
address known. If current-layer query-dependent selection must finish first, the fetch
cannot overlap preceding work without another predictor.

FP8 or INT4 H2D carries stored bytes. Conversion belongs where the selected set is
consumed. Charge it exactly once. Reused or resident FP8 rows still need conversion on
each attention use unless the runtime persistently caches BF16 output.

At full exact-cache residency, host fetch and low-rank reconstruction can disappear;
selection and sparse attention remain unless the runtime switches algorithms.

## 8. Critical-path and resource composition

Represent each event as a node with predecessors and resource demands. The latency of
one round must satisfy both:

1. the longest dependency path; and
2. each shared resource's work divided by its sustainable service rate.

Two events may overlap only if dependencies, streams/engines, buffers, and resources
allow it. H2D copy and SM compute can overlap causally while still contending for HBM
or host DRAM. When detailed contention is unavailable, report optimistic-independent
and conservative-serialized bounds.

Pipeline scheduling and queueing belong to their respective subskills, but the
latency route must export per-stage service curves (s_p(b,k,N)), not one full-model
constant. Include the LM head on its actual stage and preserve heterogeneous-layer
costs.

## 9. MTP and speculative decoding

Extract draft length and architecture from model/runtime code; do not infer it from
the number of auxiliary layers. Let (k) be verified target positions and (A) the
consecutively accepted draft prefix. A round commonly emits (A+1) committed tokens,
but confirm bonus/correction-token semantics in the runtime.

Charge:

- autoregressive draft-model or MTP-layer work;
- target-core verification at the enlarged position batch;
- attention, index, recurrent, conversion, and cache work for every verified position;
- collectives and launches; and
- any predictor horizon limitation.

Under renewal-style averaging,

\[
Y_{\mathrm{MTP}}
=\frac{\mathbb E[\text{committed tokens per round}]}
       {\mathbb E[T_{\mathrm{draft}}+T_{\mathrm{verify}}+T_{\mathrm{cache}}]}.
\]

Use the acceptance distribution when cost depends on early rejection; a ratio formed
from one mean acceptance value can be wrong. Keep no-MTP and each acceptance scenario
separate in reporting.

## 10. Prefill and TTFT

For a prompt of (N) tokens and active parameters (A), the linear arithmetic floor
starts near

\[
F_{\mathrm{prefill,linear}}\approx2AN,
\]

then adds architecture-specific dense, sparse, compressed, or recurrent attention.
Include cache writes and activation/workspace traffic. If prefill is chunked into (m)
chunks over (P) pipeline stages, a balanced forward-wave approximation has fill
factor

\[
\frac{m+P-1}{m}.
\]

This is not a burst-queue model. Export a single-request/chunk service curve to the
serving-scheduling route for simultaneous arrivals, continuous batching, and percentile
TTFT.

## 11. Validation and sensitivity

Before accepting a latency model:

1. Check every result against peak compute, HBM, conversion, and link floors.
2. Verify sequential/overlap composition against the event DAG.
3. Verify all modeled operators have one owner.
4. Confirm a resident-cache case still contains algorithmically required attention,
   selection, and recurrent work.
5. Confirm FP8 conversion changes only the events and bytes it actually touches.
6. Extend service profiles through the maximum microbatch multiplied by target
   verification positions; reject silent clamp/extrapolation.
7. Compare no-offload and offload paths at the same absolute request count and context.
8. Vary phase-specific measured ranges, not one global utilization multiplier.
9. Hold the central scheduler fixed when interpreting a parameter-sensitivity band;
   re-optimization is a separate policy comparison.
10. Label sampled p10-p90 values as sensitivity intervals, not confidence intervals.

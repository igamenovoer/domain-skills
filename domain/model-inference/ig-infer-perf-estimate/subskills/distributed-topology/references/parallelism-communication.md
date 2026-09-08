# Parallelism and Communication Reference

## 1. Inventory the physical fabric

Create a topology record before a placement estimate. Capture:

```text
node,NUMA domain,CPU memory capacity and sustained bandwidth,
GPU and actual HBM bytes,PCIe generation/width/root complex,
NVLink/NVSwitch peers,NIC and NUMA affinity,network fabric,
peer access/GDR support,link direction,measured latency,payload bandwidth
```

Use runtime and operating-system topology tools where available, then calibrate the
paths that matter. Vendor line rate is not application payload rate. Record whether a
bandwidth is unidirectional, bidirectional aggregate, one-copy, or simultaneous-copy.

For host offload, record where every layer's host cache resides. NUMA-local pinned RAM,
remote-socket RAM, peer-GPU memory, and another server's RAM take different paths.

## 2. Build explicit rank coordinates

For every process/rank, record:

```text
global rank,node,GPU,replica,DP coordinate,TP coordinate,PP stage,
EP coordinate,DCP/CP coordinate,layers,experts,weight bytes,
sequence-state components,host-memory source,collective groups
```

Do not assume every named degree multiplies to world size. Some runtimes reuse the same
ranks for TP and EP, nest context parallelism inside TP, or define attention DP and MoE
EP on different process groups. Validate the actual process-group construction.

The placement table is the shared contract with memory and latency modeling. For each
component, answer four questions:

1. Which rank owns the persistent bytes?
2. Which rank performs the arithmetic?
3. Which ranks communicate the result?
4. Which physical link and service domain carry the payload?

## 3. Parallelism semantics

### Tensor parallelism

TP can shard projection weights and query-head arithmetic while leaving other state
replicated. Classify each tensor by its actual sharded dimension.

- Conventional MHA/GQA KV heads may shard when the KV-head count and runtime layout
  permit it.
- MQA or an MLA joint latent may have no head dimension to shard and can be replicated
  on every TP rank.
- A shared sparse-index row can be replicated even while index-score arithmetic is
  head-sharded.
- Per-head recurrent state can shard across TP even when growing latent history does not.

Typical transformer TP introduces all-reduce or reduce-scatter/all-gather operations
after row/column-parallel projections. Derive their count from the model and runtime;
“two reductions per block” is a common pattern, not a universal constant.

### Pipeline parallelism

PP partitions layers, not tensor values inside a layer. Use the runtime's exact
partition rule and packed-weight manifest. Remainder layers, heterogeneous layer types,
embeddings, recurrent layers, and LM head placement can make the limiting stage differ
from an even (L/P) split.

Only an activation crossing a node boundary uses the inter-node fabric. If stages 0–3
are on one node and 4–7 on another, one forward boundary may cross the network even
though each stage performs local host-cache H2D.

### Expert and data parallelism

EP shards expert weights and commonly requires token dispatch and combine all-to-all.
Payload and imbalance depend on the router distribution, token capacity, dropped/padded
tokens, and communication mode. Model balanced, measured, and skewed cases.

DP or serving replicas duplicate weights and normally keep independent per-request
state. Prefix sharing across replicas requires explicit runtime evidence. Replicas can
increase aggregate throughput and admission, but do not reduce a request's model path.

### Decode context parallelism

DCP/CP sequence-shards growing history. For a shared latent with TP degree (T) and
decode-context degree (D), a first-order per-rank storage approximation can be

\[
M_{\mathrm{per\ rank}}\approx\frac{M_{\mathrm{stage,logical}}}{D},
\]

not (M/T), when pure TP otherwise replicates the latent. This memory reduction is
conditional on the runtime's DCP layout.

DCP also requires distributed selection/top-k or partial attention plus reductions,
all-gathers, or exchanges. Add their payload and synchronization to latency. An old
curve that divided cache by TP without communication cannot be renamed as DCP.

## 4. Point-to-point and collective roofs

For payload (B), sustainable link bandwidth (BW), and message/startup latency
\(\lambda\), a point-to-point lower bound is

\[
t_{\mathrm{p2p}}\ge\lambda+\frac{B}{BW}.
\]

For a ring all-reduce across (p) ranks, a common analytical lower-bound form is

\[
t_{\mathrm{allreduce}}
\approx2(p-1)\lambda
+2\frac{p-1}{p}\frac{B}{BW}.
\]

For ring all-gather or reduce-scatter, the corresponding one-phase approximation is

\[
t\approx(p-1)\lambda+\frac{p-1}{p}\frac{B}{BW}.
\]

These formulas assume a ring and one effective bottleneck bandwidth. Replace them with
the runtime's tree, hierarchical, NVSwitch, or topology-aware algorithm where known.
EP all-to-all needs a topology- and traffic-specific model rather than an all-reduce
formula.

Count collectives per layer and phase. Small messages are latency dominated; large
messages are bandwidth dominated. Measure both regimes.

## 5. Host cache and concurrent transfers

For per-GPU payload (B_g), (q) simultaneous ranks in a service group, single-GPU
H2D bandwidth (BW_g), shared-pair/root bandwidth (BW_s), and node DRAM bandwidth
(BW_h), the transfer cannot beat

\[
t_{\mathrm{H2D}}
\ge\max\left(
\frac{B_g}{BW_g},
\frac{\sum_{g\in s}B_g}{BW_s},
\frac{\sum_{g\in node}B_g}{BW_h}
\right).
\]

If bytes originate on another node, add or overlap the remote path according to the
actual staging pipeline:

\[
t_{\mathrm{remote}}
\ge\lambda_{net}+\frac{B_{remote}}{BW_{net}}.
\]

Do not add an IB term for stage-local CPU RAM. Conversely, do not omit network traffic
when a central cache server, remote NUMA allocation, or cross-node broadcast is used.

A load-once-then-broadcast design is a different scenario from every TP rank issuing
its own DMA. The former reduces host traffic but adds peer-copy/broadcast traffic,
buffering, and dependencies. Model both rather than silently assuming one.

Concurrent H2D can overlap SM work but still consumes copy engines, PCIe, host DRAM,
and HBM ingress. Apply both causal overlap and aggregate service-rate constraints.

## 6. Per-stage service and PP recurrence

Export a service curve for every stage:

\[
s_p(b,k,N)=t_{\mathrm{core},p}+t_{\mathrm{attention},p}
+t_{\mathrm{cache},p}+t_{\mathrm{recurrent},p}
+t_{\mathrm{collective},p}+t_{\mathrm{PP-edge},p},
\]

where (b) is decode microbatch, (k) verified positions, and (N) context. Derive
the terms from the actual stage contents. The cadence is controlled by

\[
s_{\max}=\max_p s_p.
\]

For (C_{local}) requests on one replica, microbatch (b), pipeline depth (P), and
request groups

\[
g=\left\lceil\frac{C_{local}}{b}\right\rceil,
\]

a useful closed-batch analytical recurrence is

\[
T_{\mathrm{compute}}\approx\max(P,g)s_{\max}.
\]

Treat this as a stated approximation, not a cycle-accurate result. Search implementable
(b) values and retain enough independent groups to fill the pipeline. Successive
tokens from one request are autoregressively dependent; one user cannot supply all PP
microbatches for the same decode step.

For a one-way prefill wave with (m) independent chunks/microbatches, the balanced
fill efficiency is commonly

\[
\eta_{PP}=\frac{m}{m+P-1}.
\]

This is a throughput/fill relation. Do not invert it into a per-user decode-latency
speedup. If adding unrelated requests improves per-user TPOT, require a measured batch
service curve or treat it as a likely scheduling/denominator error.

## 7. Replicas and request assignment

For (R) independent replicas and (C) active requests, assign integer users to each
replica:

\[
C_r\in\left\{\left\lfloor\frac CR\right\rfloor,
                 \left\lceil\frac CR\right\rceil\right\},
\qquad
\sum_r C_r=C.
\]

Evaluate each replica's service curve at its actual (C_r). Aggregate throughput is

\[
Y_{total}=\sum_{r=1}^{R}Y_r.
\]

Per-user latency can differ between replicas when \(C\) is not divisible by \(R\).
Do not calculate one `ceil(C/R)` latency and multiply completed requests blindly.
Shared CPU memory, PCIe roots, or NICs can also couple nominally independent replicas.

## 8. Shared-resource service constraints

Overlap changes critical latency but never deletes work. Across a scheduling interval,
for each resource (z), require

\[
T_{interval}\ge\frac{\sum_i W_{i,z}}{R_z},
\]

where (W_{i,z}) is bytes, FLOPs, messages, or another service demand and (R_z) is
sustainable rate. Apply this to:

- each GPU's SM and HBM domains;
- copy engines and PCIe endpoints;
- each shared PCIe switch/root complex;
- each NUMA/node host-memory controller;
- NVLink/NVSwitch links or switch fabric;
- NIC injection and inter-node paths.

If topology contention is unknown, provide optimistic independent-link and conservative
shared-domain bounds. Do not hide the uncertainty in one global network-efficiency
factor.

## 9. Validation checklist

Before accepting distributed results:

1. Reconcile the product/reuse of process groups with physical world size.
2. Confirm each rank's layers, experts, weights, and state from the placement table.
3. Confirm PP stage bytes and times sum to full-model work before maxima and overlap.
4. Confirm shared MLA/index state is replicated under pure TP and reduced only by an
   explicit DCP dimension.
5. Confirm DCP/EP/TP memory savings have their required collectives.
6. Confirm every communication payload follows a real source-to-destination path.
7. Roof simultaneous transfers against single endpoint, shared root/pair, host DRAM,
   and network domains.
8. Confirm the limiting stage, not an average stage, drives cadence and admission.
9. Compare aggregate and per-user throughput with one denominator and exact replica
   assignments.
10. Plot common absolute user counts when comparing topologies. Percent of each
    topology's own OOM boundary is a capacity view, not an apples-to-apples performance
    comparison.

# Memory Accounting Reference

## 1. Establish the quantity before calculating

Use bytes internally. Label every reported number as one of:

- **logical state**: one information-bearing copy for one sequence;
- **per-rank physical state**: bytes allocated on a particular accelerator rank;
- **aggregate physical state**: the sum across ranks, including replicas;
- **allocator capacity**: cache-pool bytes available after shared allocations;
- **admission**: the number of complete requests accepted by a stated policy; or
- **peak execution memory**: persistent state plus transient workspaces and activations.

“VRAM per user” is ambiguous until one of these is selected. Context must also be
defined as current live tokens, not merely input tokens. If a request starts with

\[
N_{\mathrm{prompt}}
\]

and may generate \(N_{\mathrm{output}}\) tokens, size admission at the declared peak

\[
N_{\mathrm{live}}=N_{\mathrm{prompt}}+N_{\mathrm{output}}
\]

unless tokens are evicted by a verified window policy.

## 2. Source precedence and the tensor ledger

Prefer evidence in this order:

1. allocations observed in the exact target runtime and revision;
2. the target runtime's cache/model implementation;
3. official model code, configuration, and checkpoint index;
4. official documentation or paper tensor shapes;
5. a same-family proxy implementation;
6. an explicit assumption or bounded alternative.

Configuration describes architecture intent but may not describe the serving cache.
For example, a compact MLA latent can be consumed directly by a custom kernel or
expanded into per-head K/V by a reference implementation. These are different memory
scenarios even when they use the same checkpoint.

Create one ledger row per independently placed allocation. Required columns are:

```text
component,shape,count_rule,dtype,bytes_per_scalar,scale_or_metadata_bytes,
growth,current_lifetime,cache_layers,source,revision,evidence_class,
tp_behavior,dcp_behavior,pp_owner,replica_behavior,notes
```

At minimum inventory:

- stored weights by tensor class and quantization exclusion;
- embeddings and LM head, including tying;
- K, V, or joint latent history;
- RoPE key fragments retained separately;
- sparse-search/index keys and their pooling frequency;
- sliding-window and compressed-stream history;
- recurrent/SSM/KDA matrices and convolution states;
- block tables, sequence metadata, prefix-sharing references, and scale tensors;
- CUDA graphs, collective buffers, attention/MoE workspaces, and allocator slack;
- prefill activations and any speculative/MTP buffers.

Give every row exactly one owner in the memory model. A missing owner is an omission;
two owners are double counting.

## 3. Logical growing-state formulas

### Conventional MHA, GQA, and MQA

For context (N), attention layers (L), KV heads (H_{KV,l}), head width (d_l),
and stored bytes/value (b_l), the usual separate K/V logical state is

\[
M_{KV}=N\sum_{l=1}^{L}2H_{KV,l}d_lb_l.
\]

The factor two exists only because distinct K and V tensors are retained. Include
block-scale bytes, zero points, padding, and alignment separately. MQA with one KV head
does not guarantee useful TP head sharding.

### Multi-head latent attention

For a runtime that keeps one joint latent of width (d_{c,l}) and a cached RoPE
fragment of width (d_{r,l}),

\[
M_{\mathrm{MLA}}=N\sum_l(d_{c,l}+d_{r,l})b_l.
\]

There is no automatic factor two. If the runtime expands this latent into per-head K
and V, replace the compact formula with the actual expanded tensor shapes. Confirm
whether the RoPE fragment is part of the advertised latent width before adding it.

### Sparse, compressed, and windowed attention

Sparse attention usually reduces rows read, not rows retained. Model storage and
access separately:

\[
M_{\mathrm{main},l}=n_{\mathrm{stored},l}(N)d_lb_l,
\qquad
B_{\mathrm{read},l}=n_{\mathrm{attended},l}(N)d_lb_l.
\]

For a sliding window (w_l) plus a compressed stream with ratio (c_l), one possible
runtime layout is

\[
n_{\mathrm{stored},l}(N)=\min(N,w_l)+\left\lceil\frac{N}{c_l}\right\rceil.
\]

Use this only when the implementation actually retains both components. A sparse
selector that may choose any old token still needs full historical source state or an
offloaded equivalent.

An auxiliary index pooled every (p_i) tokens with row size (e_i) consumes

\[
M_{\mathrm{index},i}=\left\lceil\frac{N}{p_i}\right\rceil e_i.
\]

The index row can have a fixed native format independent of the main KV toggle. For
example, “FP8 vector plus FP32 scale” is (d_i+4) bytes per row, not (2d_i) under a
BF16-main-cache scenario.

### Recurrent and linear-attention state

Recurrent state is commonly (O(1)) in context rather than (O(N)). For (H_s)
heads, state width \(d_s\times d_s\), and state bytes \(b_s\),

\[
M_{\mathrm{state},l}=H_sd_s^2b_s+M_{\mathrm{conv},l}+M_{\mathrm{other},l}.
\]

It is still per sequence. Record mixed dtypes and whether heads are physically
sharded. Do not erase this state because the model has no growing KV on those layers.

### Quantized values and metadata

For block size (g), value bytes (b_q), and one (b_s)-byte scale per block, the
unpadded average is

\[
b_{\mathrm{effective}}=b_q+\frac{b_s}{g}.
\]

Apply ceiling and alignment to actual blocks:

\[
M=\left\lceil\frac{V}{g}\right\rceil(gb_q+b_s)+M_{\mathrm{zero\ point}}+M_{\mathrm{padding}}.
\]

Checkpoint “FP8” or “INT4” may exclude embeddings, attention projections, recurrent
layers, or the LM head. Prefer the exact checkpoint index byte total and tensor-level
quantization map to parameter-count multiplication.

## 4. Algorithm overlays and offload state

An offload algorithm often retains more HBM state than its selected fraction. For a
ShadowKV-like example with context \(N\), low-rank key rank \(r\), exact cached width
\(d\), chunk size \(c\), selected rows \(S=\lceil\alpha N\rceil\), landmark rows
\(n_L\), and exact buffer rows \(n_B\), a representative value count is

\[
V_{\mathrm{overlay},l}=Nr+rd+n_Ld+n_Bd.
\]

These terms can represent the long (U) factor, (SV), landmarks, and selected,
outlier, local, and reserve rows. Use the paper and selected implementation to derive
the exact formulas and dtypes; do not reuse constants across algorithms.

Also count the host-resident exact history:

\[
M_{\mathrm{host}}=\sum_l n_{\mathrm{host},l}(N)d_lb_l
\]

plus pinned-memory, alignment, and duplicate-staging overhead. If host capacity is
declared unlimited, say that this removes only a capacity constraint; host DRAM and
H2D bandwidth remain finite latency and throughput constraints.

For partial residency, replace components according to the implementation's lifetime.
If only whole layers can be retained,

\[
n_{\mathrm{resident}}=\operatorname{round}(pL),
\qquad
p_{\mathrm{exact}}=\frac{n_{\mathrm{resident}}}{L}.
\]

Publish \(p_{\mathrm{exact}}\), not just requested \(p\). Determine whether resident
exact state replaces or coexists with low-rank factors and buffers.

## 5. Physical placement

Calculate logical state before applying placement. For component (x), layer (l),
rank (r), and request (u), define an explicit ownership fraction

\[
\phi_{x,l,r,u}\in[0,1].
\]

Then

\[
M_{r,u}=\sum_{x,l}\phi_{x,l,r,u}M_{x,l,u}.
\]

The fraction is not automatically (1/TP):

- PP assigns disjoint layer sets to stages.
- Conventional KV heads may shard across TP only if the runtime and head geometry do.
- A shared MLA latent and shared sparse index are commonly replicated under pure TP
  with decode-context-parallel degree one.
- DCP or context parallelism may sequence-shard growing history, but requires its own
  distributed-attention communication model.
- Per-head recurrent state may shard across TP even when latent history does not.
- DP and independent replicas duplicate weights and per-request state across groups;
  each request belongs to one replica unless prefix/state sharing is implemented.

Use the actual PP partitioning rule and layer types. With heterogeneous layers, the
largest memory stage may not be the largest compute stage. Retain a rank-level table
rather than reducing placement to “total bytes divided by GPUs.”

## 6. Admission and peak memory

For rank (r), observed HBM bytes (H_r), allocation fraction (u_r), packed weights
(W_r), runtime reserve (R_r), static allocations (A_r), and marginal request
bytes (m_r),

\[
C_{r}=\left\lfloor
\frac{u_rH_r-W_r-R_r-A_r}{m_r}
\right\rfloor.
\]

A replica admits

\[
C_{\mathrm{replica}}=\min_{r\in\mathrm{replica}}C_r.
\]

Sum replica capacities only when requests can be assigned independently. With
nonuniform lengths, page allocation, shared prefixes, or mixed prefill/decode, use a
packing or trace model rather than multiplying one homogeneous request size.

Use actual device bytes from the runtime when possible. Vendor “80 GB,” checkpoint
“GB,” GiB, and simulator `GB/s` units are not interchangeable. Convert through bytes:

\[
1\ \mathrm{GB}=10^9\ \mathrm{bytes},
\qquad
1\ \mathrm{GiB}=2^{30}\ \mathrm{bytes}.
\]

Weight conversion at consumption does not imply a permanent BF16 weight copy, but
some runtimes allocate converted workspaces or cached packed variants. Inspect the
implementation or bound both cases.

Memory admission is not useful concurrency. Also compute a latency/SLO ceiling in the
serving model. A cache allocator may preallocate most free HBM, so process memory from
`nvidia-smi` is not a per-sequence growth measurement.

## 7. Independent checks

Before handing memory results to latency or scheduling:

1. Hand-calculate at least one full-model logical context total.
2. Confirm PP stage component sums reproduce that logical total before replication.
3. Confirm the reported limiting rank fits \(C_{\max}\) requests and fails at
   \(C_{\max}+1\).
4. Verify growing state is monotone in live context and request count.
5. Verify pure-TP shared MLA per-rank history does not shrink when TP increases; its
   aggregate copies should grow unless DCP is enabled.
6. Verify fixed state remains context-independent and side-cache dtypes remain
   independent of unrelated toggles.
7. Compare the native runtime, proposed overlay, fully resident overlay, and any DCP
   alternative using the same weights, reserve, and unit basis.
8. Preserve prefix sharing as a separate workload case; never assume independent
   users share state.

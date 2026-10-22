# Network Bridge for an Isolated VDI Gateway

Use this reference when the arm64 host cannot route to the VDI gateway directly, but can reach an intermediate host (over SSH) that can. All options below carry TCP only.

## Workflow

1. Confirm the topology: host A (arm64, runs the client) → host B (SSH-reachable from A, routes to gateway G). Record only placeholders in notes, not real addresses.
2. Pick an option from **Options** in order of preference.
3. Verify from inside the client container before starting the GUI: `proxychains4 curl -k https://<gateway>/` (or the equivalent for the chosen option) returns HTTP 200.
4. Keep the invariants in **Guardrails**.

If none of the options fit (for example UDP is a hard requirement), stop and report the limitation to the user instead of inventing a tunnel with side effects on host B.

## Options

### Option 1: Existing HTTP CONNECT proxy on B + proxychains-ng (preferred)

Use this when B already runs a proxy such as Squid. It changes nothing on B.

Inside the client image, `/etc/proxychains4.conf`:

```
strict_chain
proxy_dns
localnet 127.0.0.0/255.0.0.0
localnet <B-ip>/255.255.255.255
[ProxyList]
http <B-ip> <proxy-port>
```

- The `localnet` lines belong to the global section, not `[ProxyList]`.
- Loopback exclusion is mandatory: the client GUI reaches its own local agent at `127.0.0.1:31113`.
- Exclude the proxy's own address, or proxychains loops.
- Wrap only the client processes (`proxychains4 -f /etc/proxychains4.conf <binary>` inside the launcher's `runuser env`); leave the rest of the container direct.
- proxychains intercepts only dynamically linked TCP `connect()` calls; static binaries and UDP are not covered.

### Option 2: SSH dynamic forward (SOCKS5) on A + proxychains-ng

Use this when B has no proxy but SSH access exists:

```bash
ssh -N -D 127.0.0.1:1080 <user>@<B> &
# proxychains4.conf: socks5 127.0.0.1 1080   (keep the same localnet rules)
```

Same proxychains caveats as Option 1. Keep the SSH client on host A, outside the container, so the container sees only a loopback SOCKS endpoint.

### Option 3: sshuttle through B

Use this when whole-subnet transparent TCP routing is wanted and both ends allow it:

```bash
sshuttle -r <user>@<B> <gateway-subnet>/<mask> -x <A-local-subnets>
```

Requires sudo on A and python3 on B. Cover the client container's traffic by running sshuttle on the host with the docker bridge range included. This avoids `LD_PRELOAD` entirely, which also sidesteps the setuid/`LD_PRELOAD` interactions of the client.

### Option 4: Single-port forward

Use this only when the whole client protocol traverses one TCP endpoint (commonly gateway port 443):

```bash
ssh -N -L 127.0.0.1:1443:<G>:443 <user>@<B>
# point the client at 127.0.0.1:1443
```

Verify certificate/hostname handling; some client builds refuse a mismatched address.

## Constraints

- Every SSH/CONNECT-based path is TCP-only. UDP probes, QUIC, and VDI UDP media acceleration cannot traverse them; the client negotiates a TCP fallback for the display channels, which is sufficient for desktop use.
- Expect added latency through B; interactive desktop use remains usable, bulk media less so.

## Guardrails

- DO NOT add routes, iptables rules, or forwarding on host B, and do not install software there; choose an option that uses only existing services on B.
- DO NOT forward the client's loopback agent port through any tunnel.
- DO NOT record real host addresses of A, B, or G in skill sources or committed notes; use placeholders.

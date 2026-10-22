# Session Crash Fix: libusb Hotplug NULL-Context SIGSEGV

Use this reference when the Sangfor VDI session dies a few seconds after the desktop windows appear. It documents the known root cause for the 5.9.1.3028 client and a generic forensics recipe to re-derive the fix for other builds.

## Workflow

1. Confirm the symptom per **Symptom Recognition**.
2. If the build is `com.sangfor.vdi` 5.9.1.3028 amd64 (`ubuntu.deb`), apply the verified patch in **The Patch** directly; otherwise derive fresh offsets with **Deriving the Patch on a New Build**.
3. Make the launcher re-apply the patch idempotently at every start (**Launcher Integration**).
4. Restart the container, have the user log in again, and verify the session stays up past window creation and past the previous crash point in `vdi_session.log`.
5. If the patch target bytes do not match, do not write anything; fall back to the derivation recipe.

## Symptom Recognition

All of these together identify this bug:

- After a successful login and resource selection, `vdi_session` connects to the VM display channels and creates its X11 windows, then vanishes after roughly two to three seconds.
- The GUI later shows a resource-acquisition or network error; the message is misleading — the network path is fine.
- `vdi_session.log` ends right after `RedWindow` creation and the line `start hotplug event listener` (`usb_redirector_manager.cpp`).
- The client's libusb log shows `libusb init failed` and the usbredir channels warn `init redirhost failed` shortly before the death.
- The same crash hits the native arm64 client build (window flash), because it is the same NULL-context code path.

Root cause: `libusb_init` fails in the container, leaving a NULL libusb context. `UsbRedirectorManager::start_hotplug_event_listener` calls `libusb_hotplug_register_callback(NULL, ...)`; the bundled libusb does not NULL-check the context and enters `pthread_mutex_lock(NULL + 0x90)`, whose first instruction dereferences `[rdi+0x10]` at address `0xa0` → SIGSEGV. The process dies before anything logs the fault.

## The Patch

Patch `vdi_session`: replace the first `call libusb_hotplug_register_callback` inside `start_hotplug_event_listener` with `mov eax,-1`, so the function takes its designed error path (logs, returns -1) and never spawns the hotplug thread. Effect: USB hotplug/redirection stays disabled — it already was, since there is no libusb context — while display, keyboard, mouse, and audio work.

Verified for `com.sangfor.vdi` 5.9.1.3028 amd64 (`vdi_session` 4657000 bytes, non-PIE):

- Patch site: vaddr `0x54689b`, file offset `0x14689b`.
- Original bytes: `e8 b0 56 ed ff` (`call 0x41bf50`, the PLT stub of `libusb_hotplug_register_callback`).
- Replacement bytes: `b8 ff ff ff ff` (`mov eax,-1`).
- The only two call sites of that PLT stub are `0x54689b` and `0x5469ad`, both inside the same function; patching the first makes the second unreachable.

## Deriving the Patch on a New Build

Use this recipe when the verified offsets do not apply. It avoids several tooling traps specific to qemu-user; see **Known Dead Ends** before improvising.

1. Enable guest crash dumps:
   - Ensure `RLIMIT_CORE` is unlimited for the container processes (Docker's default already is).
   - Launch the client agents with a cwd writable by the container user (its home directory). qemu-user writes a guest ELF core named `qemu_vdi_session_<timestamp>_<pid>.core` into the guest cwd when a guest dies of an unhandled fatal signal. Host apport never sees container crashes, and qemu's `guest_errors` log does not cover this death.
   - Optionally set `QEMU_STRACE=1` on the agent processes; spawned children inherit it and write syscall traces to the agents' stderr files.
2. Trigger the crash by logging in and opening the resource; collect the core.
3. Extract the faulting thread's registers with `scripts/parse-qemu-core.py <core>` (host `readelf`/`objdump` on an arm64 box do not decode x86_64 core notes; the script needs only python3). The thread with `cursig=11` is the faulting one; note `rip`, `rsp`, and the argument registers.
4. Attribute `rip` to a library. qemu cores carry no NT_FILE note, so correlate instead: in the QEMU strace output, find the session pid's `openat(...so...) = N` line and the immediately following `mmap(...) = 0x...` lines; the base mmap covering `rip` names the library.
5. Disassemble around the fault with `scripts/disasm-window.py <binary-or-lib> <hex-addr>` (uses the capstone venv; install capstone in a venv when missing). Confirm the faulting instruction and its enclosing function prologue. For this bug family the faulting instruction is `mov eax,[rdi+0x10]`, the prologue of `__pthread_mutex_lock`, with `rdi` holding `NULL + <mutex offset>`.
6. Reconstruct the caller chain from the faulting thread's stack: dump qwords at `rsp` upward from the core, keep values inside the main binary's text range (non-PIE: around `0x400000` upward) as return-address candidates, and disassemble around each. Embedded stack strings (the binary is rich in `Class::method` log strings) identify the calling function by name.
7. Locate the patch site: disassemble the calling function, find the `call` into the crashing library PLT stub, and verify the function has a designed error path (a negative return value that logs and returns, with no thread spawned on that path). Scan the whole `.text` for other call sites of the same stub and reason about reachability.
8. Patch as in **The Patch**: overwrite the 5-byte `call` with `b8 ff ff ff ff`. Keep a pristine copy of the original binary for rollback.

## Launcher Integration

The launcher must re-apply the patch idempotently, because container recreation restores the original binary from the image. Gate the write on the original byte so re-runs are no-ops:

```bash
_vs=/usr/local/sangfor/vdiclient/bin/vdi_session
if [ "$(od -An -tx1 -j $((PATCH_FILE_OFFSET)) -N1 "$_vs" | tr -d ' \n')" = "e8" ]; then
    printf '\xb8\xff\xff\xff\xff' | dd of="$_vs" bs=1 seek=$((PATCH_FILE_OFFSET)) conv=notrunc
fi
```

Set `PATCH_FILE_OFFSET` from the derivation recipe (`0x14689b` for the verified build).

## Known Dead Ends

All of these were tried and failed on this stack; do not repeat them:

- `libSegFault.so`, `catchsegv`, and clean-exit probe libraries: the app's own crash handler double-faults under qemu-user and nothing is ever logged.
- Shell-script wrappers around `vdi_session`: securestart rejects the mismatched `/proc/self/exe`; the client never starts.
- `LD_PRELOAD` symbol interposition (`kill`, `waitpid`, `sigaction`, even constructor-only libraries): any exported interposed symbol segfaults `vdi_client` at startup under qemu-user.
- A raw-syscall signal-handler watchdog library (reinstalling handlers on a 20 ms thread): handlers install fine and still never fire under qemu-user.
- `QEMU_LOG=guest_errors`: the first fault is "handled" by the app's handler, and the double fault bypasses this logger entirely.
- Host-side apport: it deliberately ignores processes inside containers; only host processes produce `/var/crash` entries.
- Planting Xcursor theme files for the VM's all-zero-hash invisible cursor: fixes cursor-lookup noise in the trace, not the crash.

## Guardrails

- DO NOT patch any byte whose original content was not verified against the expected `e8` call encoding.
- DO NOT patch `vdi_webui_agent`, `vdi_client`, or libraries to reach the same goal; the verified site is inside `vdi_session` only.
- DO NOT distribute the patched binary outside the user's own machines.

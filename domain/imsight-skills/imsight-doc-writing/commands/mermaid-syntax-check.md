# Mermaid Syntax Check

Check a Mermaid graph with the `mermaid` package's `mermaid.parse()` API without rendering SVG, PNG, or PDF and without launching a browser. Accept either Mermaid source text or one `.mmd` file, prefer a project-scoped package over a global package, and prefer Bun over npm and Node.

## Workflow

When this subskill is invoked, execute the following steps in order.

1. **Resolve the project scope**. Use the project directory named by the user, or the current working directory when no project is named. Account for a JavaScript workspace root when the current directory is a nested package.
2. **Normalize the input**. Treat an existing `.mmd` path as file input; otherwise treat the supplied graph as Mermaid source text. Do not interpolate source text into executable JavaScript or an unquoted shell command.
3. **Find an installed `mermaid` package** using the exact priority in **Package Resolution**. Select the first usable installation and record its version and package base.
4. **Select the runtime**. Use Bun when `bun` is available. Otherwise use Node from the npm toolchain. Do not use `@mermaid-js/mermaid-cli`, Puppeteer, Playwright, Chrome, or Chromium for this syntax-only check.
5. **Run the parser** from the selected package base using the **Browser-Free Evaluation Body**. Pass an absolute `.mmd` path as the evaluator's first argument, or pass source text through standard input.
6. **Return the result** following **Result Contract**. Include the Mermaid version and whether the selected package was project-scoped or global when that context helps diagnose a mismatch.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from the package-resolution rules, runtime priority, and input forms below, then execute the plan.

## Package Resolution

Resolve an installed package before considering installation. A package base is the directory whose `node_modules/` contains the selected `mermaid` package.

1. Search the project scope first.
   - Inspect the target package directory and its workspace ancestors up to the project or workspace root for `node_modules/mermaid/package.json`.
   - Treat a workspace-hoisted package as project-scoped when its `node_modules/` belongs to that workspace.
   - Prefer Bun as the runtime even when npm originally installed the local package; the installed package is the authority.
2. If no project-scoped installation exists, check Bun's global packages.
   - Confirm the package with `bun pm ls -g`.
   - Use `${BUN_INSTALL:-$HOME/.bun}/install/global` as the usual Bun global package base, and verify that `<base>/node_modules/mermaid/package.json` exists before selecting it.
3. If Bun has no global installation, check npm's global packages.
   - Confirm the package with `npm ls -g --depth=0 mermaid`.
   - Get the global `node_modules` directory with `npm root -g`; its parent is the package base from which bare imports resolve.
4. If no installed package is usable, report that condition instead of silently downloading one.
   - When the user authorizes installation, prefer a project-scoped development dependency: `bun add --dev mermaid`, then `npm install --save-dev mermaid` if Bun is unavailable.
   - Do not install `@mermaid-js/mermaid-cli` for syntax checking.

Do not rely on Bun's fallback resolution of global packages from arbitrary directories. Change the evaluator's working directory to the selected package base so the chosen local or global package is explicit and reproducible.

## Browser-Free Evaluation Body

Run the following JavaScript as an ES module through the selected runtime. When using `--eval`, both Bun and Node expose the first trailing argument as `process.argv[1]`; omit that argument to read Mermaid source from standard input.

```js
import { readFile } from "node:fs/promises";

import DOMPurify from "dompurify";

Object.assign(DOMPurify, {
  addHook: () => {},
  sanitize: (value) => String(value),
});

const { default: mermaid } = await import("mermaid");

const inputPath = process.argv[1];
const chunks = [];
if (!inputPath) {
  for await (const chunk of process.stdin) {
    chunks.push(Buffer.from(chunk));
  }
}

const source = inputPath
  ? await readFile(inputPath, "utf8")
  : Buffer.concat(chunks).toString("utf8");

if (!source.trim()) {
  console.error("Mermaid input is empty");
  process.exit(2);
}

try {
  const result = await mermaid.parse(source);
  console.log(`Valid Mermaid syntax (${result.diagramType})`);
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exit(1);
}
```

Use one of these evaluator forms from the selected package base:

```text
bun --eval '<evaluation body>' /absolute/path/to/graph.mmd
node --input-type=module --eval '<evaluation body>' /absolute/path/to/graph.mmd
```

For source text, feed the exact text through standard input and omit the file argument:

```text
<source-producing command> | bun --eval '<evaluation body>'
<source-producing command> | node --input-type=module --eval '<evaluation body>'
```

Use a quoted heredoc, a tool-provided standard-input channel, or another non-interpolating mechanism when the source contains backticks, dollar signs, quotes, or shell metacharacters. If an execution tool cannot safely carry the evaluation body inline, write it to a temporary `.mjs` file inside the selected package base, run it, and remove only that temporary file afterward.

## Why the Sanitizer Shim Exists

Mermaid parsing can sanitize node and edge labels even though it does not render a diagram. In a headless Bun or Node process, the default `dompurify` export may lack `addHook` or `sanitize`, which makes valid labeled diagrams fail before `mermaid.parse()` returns.

The evaluation body supplies identity sanitizer methods only for a syntax check. It does not create a DOM, launch a browser, or render output. Never reuse this shim for `mermaid.render()` or for publishing untrusted HTML because it deliberately bypasses sanitization.

## Result Contract

- Exit `0` and report `Valid Mermaid syntax (<diagram-type>)` when parsing succeeds.
- Exit `1` and preserve Mermaid's parser diagnostic when syntax or the diagram type is invalid.
- Exit `2` for command-usage failures such as empty input, missing runtime, or no installed `mermaid` package.
- Do not create an SVG or other diagram artifact unless the user separately requests rendering.

## Troubleshooting

- If a valid graph with labeled nodes fails with `DOMPurify.addHook is not a function` or `DOMPurify.sanitize is not a function`, confirm that the sanitizer shim runs before the dynamic `import("mermaid")`.
- If `Cannot find package 'mermaid'` appears, confirm the evaluator is running from the selected package base and that `node_modules/mermaid/package.json` exists there.
- If the globally installed version accepts syntax that the project renderer rejects, install or use the project's exact Mermaid version and rerun the check.
- If the input is Markdown rather than a standalone `.mmd` graph, extract each fenced `mermaid` block and check it separately; do not pass the whole Markdown document to `mermaid.parse()`.

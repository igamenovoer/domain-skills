---
metadata:
  skill_invocation_notation: >
    Top-level skill entrypoints use SKILL.md. Parent-scoped subskill entrypoints use
    SKILL-MAIN.md and are loaded explicitly through their parent; nested SKILL.md is
    accepted only as legacy input when SKILL-MAIN.md is absent.
    Skill and subskill entrypoints use bare object paths: `X` invokes skill X and
    `X->Y->Z` invokes subskill Z. Subcommands use parenthesized components:
    `X->cmd()` invokes a direct subcommand, `X->Y->cmd()` invokes a subcommand of
    subskill Y, and `X->parent()->child()` invokes child subcommand child exposed
    by parent subcommand parent. Intermediate subcommands act as object generators.
    Forms such as `X()` and `X->Y()` are invalid for skill or subskill entrypoints.
---

# Add Hidden Slides and Reveal Links

## Overview

Implement optional appendix or detail slides that ordinary navigation skips, while links can open them during a presentation. Return restores the actual origin, including its animation/click position. Multiple source slides and nested detail visits are supported.

## Workflow

1. **Resolve the target presentation**. Identify the deck entrypoint, detail content, source slides or footnotes, existing navigation, and build commands. Ask only for information needed to choose the correct artifact.
2. **Choose the hiding semantics** using **Visibility Modes**. For runtime reveal, keep the target compiled and select the optional-navigation behavior below.
3. **Inspect version and integration points**. Check the installed Slidev APIs and any existing root setup, navigation extensions, Vue components, route aliases, and presenter synchronization.
4. **Plan the smallest complete integration**. Choose stable target aliases, control labels and locations, origin/return behavior, and a direct-entry fallback. Use **Navigation Contract**.
5. **Install or adapt the reusable parts**. Follow **Portable Resources** and merge with existing project files. Keep the runtime independent of this skill's filesystem location.
6. **Add the optional slide and reveal links**. Apply **Slide and Link Markup**, retaining the user's layout, language, and notes. Several source links may share one target alias.
7. **Build and exercise the interaction**. Run the relevant project build, then the applicable cases in **Verification Matrix** against the built presentation. Use a small isolated fixture for unfamiliar navigation behavior.
8. **Document the controls and delivery scope**. Explain normal navigation, reveal, return, direct entry, and export behavior in the project's existing documentation or speaker notes.
9. **Report the result**. Name changed files and entry links, say what was verified, and identify any remaining limitation without overstating support.

If the user's task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from the visibility, navigation, integration, and verification contracts below, then execute it.

## Invocation

Invoke `imsight-doc-writing->slidev->add-hidden-slides()` with the target deck and desired source/detail relationship. The command handles new optional pages, conversion of existing pages, and additional links to an already optional page.

## Visibility Modes

| User intent | Implementation | Consequence |
| --- | --- | --- |
| Exclude a page entirely | Native `hide: true` or `disabled: true`, after checking the installed version | The parser omits the page; a built deck cannot reveal it through a button. Remaining page numbers may change. |
| Skip a page until explicitly requested | Keep the page compiled; add custom optional metadata and navigation behavior | Ordinary Next/Previous skips it. A link or direct route can open it without rebuilding. |
| Remove a table-of-contents entry | Native `hideInToc: true` | Affects the ToC only; it does not by itself change navigation or overview access. |

The runtime-reveal default is a temporary detail visit: the optional page stays outside ordinary Next/Previous even after it has been opened. If the user wants a reveal to permanently unlock that page for the rest of the session, explicitly adapt the state model and test that different behavior.

Optional navigation is not content removal. The bundled implementation retains page numbers, permits overview/direct-route access, and includes optional slides in a default export. If the user needs them excluded from overview, print, or PDF/PPTX, handle each surface explicitly using the installed version's supported filtering or export ranges. Reveal controls themselves are suppressed in print/export views.

## Navigation Contract

### Default flow and explicit reveal

- Recognize a project-owned frontmatter flag such as `optionalSlide: true`; it is a custom convention, not native Slidev functionality.
- Keep a normal opening slide and use stable, unique `routeAlias` values for reveal targets. Do not navigate by a display number that may shift after edits.
- Skip flagged pages in Next, Previous, direct next/previous-slide controls, and the presenter's next-slide preview. Preserve click/animation progression within a normal slide.
- Permit intentional navigation through a reveal link, overview, or direct URL. Validate reveal targets so missing or nonoptional destinations produce a useful failure rather than an incorrect jump.
- Handle the first/last reachable page and consecutive optional pages without loops or out-of-range routes.

### Return location

- Record the originating route for each actual entry into an optional page. Preserve its path or stable alias, query parameters including click position, and relevant hash.
- Compare resolved slide identities when detecting a new entry; a numeric route and an alias can refer to the same page.
- Use a stack of origins, not one fixed page number. Nested visits return one level at a time, and links from different slides restore their own origins.
- Suppress recording during a Return operation so a nested return does not create another history entry. Clear stale detail history after an ordinary exit to the main flow.
- For direct entry with no origin, provide a working fallback: overview when supported, otherwise a normal start page. A browser reload may lose session-local return history; the fallback must still work.
- Do not rely solely on `history.back()`: click progression, reloads, and unrelated browser history can make it return to the wrong state or leave the presentation.

### Controls and synchronization

- Integrate through the installed Slidev navigation/root APIs and preserve existing project setup. Cover keyboard, toolbar, and presenter preview consistently rather than intercepting only one key.
- Use labeled, keyboard-accessible links and buttons. Prevent the reveal click from also advancing the source slide.
- Release focus from the activated link/button before navigating when Slidev suppresses shortcuts while those elements are focused. Test arrow keys immediately after both reveal and return.
- Keep ordinary Slidev page synchronization working. Test the controlling presenter and the audience view together when that mode is in scope; direct page changes must not be rejected by a viewer-only hidden-state guard.
- Install lifecycle listeners once through the deck's setup. Avoid creating global handlers for every mounted or preloaded slide.

## Portable Resources

[../assets/optional-slides/](../assets/optional-slides/) is a standalone example bundle qualified with Slidev 53.0.0. It is a starting implementation, not a promise that every Slidev version exposes identical APIs.

| Resource | Role |
| --- | --- |
| `composables/optionalSlides.ts` | Optional-page selection, origin stack, reveal, and return |
| `setup/root.ts` | Installs the navigation extension through the root setup |
| `components/OptionalSlideLink.vue` | Reveal link using a stable alias |
| `components/OptionalSlideReturn.vue` | Return control and direct-entry fallback |
| `slides.md` | Five-slide smoke fixture with two origins, click steps, and nested detail |

For a new isolated smoke fixture, copy the entire bundle into project-approved scratch space and build it using the resolved Slidev command. For an existing deck, copy only missing implementation files, merge the root setup into existing setup, and adapt the requested pages. Do not overwrite the user's deck entrypoint with the fixture. Reuse local dependencies or already installed global tools; do not hardcode a developer's global npm/Bun paths or add an unrelated dependency stack.

The template does not need a server API or a rebuild to open an optional page. Preserve that property when adapting it. Keep session-only navigation state separate from the presentation's technical data and content.

## Slide and Link Markup

These are illustrative aliases, titles, labels, and paths. Adapt their meaning and styling to the user's deck; do not hardcode the example content.

An optional target remains included:

```markdown
---
routeAlias: method-details
optionalSlide: true
hideInToc: true
---

<OptionalSlideReturn />

# Method details
```

A source slide or footnote opens it:

```html
<OptionalSlideLink to="method-details">How was this measured?</OptionalSlideLink>
```

To add another source, reuse the target alias with another `OptionalSlideLink`. The Return destination is recorded at runtime; it is not specified in the detail slide. Place controls in the existing footnote/header grid, keep them readable, and avoid overlapping chart labels or changing the data to make room.

## Verification Matrix

Build using the target project's real command and test a static served build when static delivery matters. A build pass is insufficient for navigation changes. Use the available Playwright/browser tooling and inspect console errors as well as screenshots.

| Case | Required observation |
| --- | --- |
| Default forward/backward | The optional page is skipped in both directions, including consecutive optional pages. |
| Keyboard and toolbar | Both navigation surfaces follow the same flow; click steps complete before advancing slides. |
| Reveal link | Opens the requested alias; it does not accidentally advance the source. |
| Return after partial animation | Restores the origin's click position as well as its page. |
| Multiple origins | The same detail page returns correctly to either source. |
| Nested detail | Inner Return restores the outer detail; another Return restores the main source. |
| Keyboard after controls | Arrows work immediately after clicking Reveal and Return. |
| Presenter next preview | Previews the next normal page after the current slide's remaining clicks. |
| Presenter and audience | Reveal and Return synchronize the same page and click state across both views. |
| Direct URL or reload | A missing origin produces a useful fallback, never a broken Return. |
| Alias and numeric route | Resolving the same page under another route spelling does not push itself onto the return stack. |
| Print/export | Controls are suppressed; inclusion of optional pages matches the explicitly documented export policy. |
| Layout | Controls stay inside the slide, remain legible, and do not obscure existing content. |

Record tested Slidev/browser versions and material gaps. Prefer focused regression coverage for return-state and focus behavior over tests that merely mirror implementation details. Keep logs, screenshots, and temporary builds in the target project's approved generated-output location.

## Guardrails

- DO NOT set native `hide: true` or `disabled: true` on a runtime-reveal target.
- DO NOT hardcode one Return destination for a detail slide shared by multiple sources.
- DO NOT implement skipping for only one keyboard shortcut while leaving toolbar or presenter preview behavior inconsistent.
- DO NOT overwrite existing root setup or navigation extensions when integrating the example.
- DO NOT claim that skipping ordinary navigation removes content from the built bundle, overview, or exported documents.

## Output Contract

Deliver the optional pages, source links, origin-aware return controls, navigation integration, and concise usage notes. Summarize how to open and return, which navigation/export surfaces were verified, and any behavior that requires further project-specific adaptation.

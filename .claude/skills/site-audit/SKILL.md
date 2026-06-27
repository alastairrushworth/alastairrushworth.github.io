---
name: site-audit
description: One-stop deep audit of alastairrushworth.com across five dimensions — security/vulnerability detection, SEO, accessibility, best-practice, and code/link issues. Checks both the local source files (what you edit) and the live deployed host (what users & crawlers get). Use for a full health check of the site, before/after a redesign, when reviewing a sub-site, or any time you want one comprehensive pass over everything. Defers to the sitemap-check skill for crawlability depth.
---

# site-audit

A single deep pass over the whole site, covering the five things you asked for:

| Dimension | What it looks at |
|---|---|
| **Security / vulnerabilities** | reverse-tabnabbing (`target=_blank` w/o `rel=noopener`), mixed content, missing Subresource Integrity, leaked secrets/keys, TLS & HTTP→HTTPS, security response headers |
| **SEO** | `<title>`/description lengths, canonical, Open Graph, single `<h1>`, plus full crawlability via `sitemap-check` |
| **Accessibility** | `lang`, zoom-blocking viewport, `<img>` alt, link text, form labels, heading order, **WCAG colour contrast** |
| **Best practice** | doctype, charset, page weight, compression, caching, external request count |
| **Code / links** | duplicate IDs, HTML well-formedness, internal **and** external link resolution |

The site is a static GitHub Pages site: the root user-site lives in **this** repo
(hand-authored HTML/CSS), and several independent project sites are served under
the same host from separate repos. This audit checks the source here **and** the
live host.

## How to run

```bash
.claude/skills/site-audit/audit.sh                       # full audit of https://alastairrushworth.com
.claude/skills/site-audit/audit.sh https://example.com   # any host
.claude/skills/site-audit/audit.sh --offline             # source-only checks, no network (good pre-deploy)
```

Needs `curl` (+ `xmllint`, `python3` for richer checks — all preinstalled on
macOS). The live checks reflect what's **deployed**, so run them after a deploy.
Exit code is `0` when there are no FAILs, `1` otherwise.

The set of HTML files and links is **discovered** from `git ls-files '*.html'` and
the pages themselves — nothing is hardcoded, so it stays correct as the site grows.

## Procedure (run this in order)

1. **Run the script** (`audit.sh`, both online so you get the live checks too).
2. **Do the judgment passes the script can't fully automate** — open the flagged
   files and check:
   - **Contrast in context.** The script computes WCAG ratios assuming the page
     `--bg`. Purely *decorative* text (separators, the `›`/`→`/`~` glyphs) is
     exempt from WCAG; real body/footer text is not. Decide per use whether a
     low-ratio token (e.g. `--faint`) is actually carrying readable content.
   - **Alt-text quality**, not just presence — does it describe the image's
     purpose? Empty `alt=""` is correct only for decorative images.
   - **Heading & landmark semantics** — does the heading text outline the page,
     and are `<header>/<main>/<nav>/<footer>` used meaningfully?
   - **SEO content quality** — is each `<title>`/description unique, accurate and
     compelling, not just within the length window?
   - **Real bugs the grep can't see** — read the diff/source for logic, broken
     layout, dead code.
3. **Compile a consolidated report** grouped by the five dimensions, each finding
   with: severity (FAIL/WARN), the file + line, why it matters, and the concrete
   fix. Lead with the FAILs. Offer to apply the fixes.

## Reading the output

- **FAIL** — a real defect: breaks security (tabnabbing, mixed content, exposed
  secret), accessibility (zoom blocked, missing alt, contrast < 3:1), or
  correctness (broken internal link, duplicate ID). Fix these.
- **WARN** — sub-optimal or needs a human call (short meta description, missing
  security header, contrast 3–4.5:1, an external link that timed out).
- **·** — informational (inventory, platform notes, redirect hops).

The **SEO · crawlability** section shells out to the `sitemap-check` skill and
prints *its own* PASS/FAIL block — those counts are separate from this script's
summary. Treat its FAILs as part of the audit.

## Known platform caveats (don't mis-report these)

- **Security response headers** (CSP, X-Frame-Options, Referrer-Policy, HSTS,
  X-Content-Type-Options, Permissions-Policy) show as WARN because **GitHub Pages
  cannot set custom response headers**. The realistic mitigations are a
  `<meta http-equiv="Content-Security-Policy">` tag in each page and a framebusting
  guard — not a server config. Recommend those, don't tell the user to "set a
  header" the platform won't honour.
- **External links returning 401/403/405/429/999** are reported as info, not FAIL —
  that's bot-blocking (LinkedIn returns `999`), not a dead link. Verify in a
  browser if in doubt.
- **HTML validity**: the macOS-bundled `tidy` (2006) and `xmllint --html` predate
  HTML5 and falsely flag `<header>/<main>/<section>/<footer>`. The script gates
  `tidy` on a modern version and filters that noise from `xmllint`, so a PASS here
  means genuinely well-formed HTML5. For an authoritative check, paste into the
  W3C validator (`https://validator.w3.org/nu/`).

## Fixing common findings

- **`target=_blank` without `rel`** → add `rel="noopener noreferrer"` to the `<a>`.
- **Contrast too low on real text** → darken the background or lighten the token in
  the `:root` CSS variables; re-run to confirm the new ratio clears 4.5:1.
- **Short/missing meta description or Open Graph** → edit the `<head>` of that page;
  mirror the richer `<head>` in the root `index.html` as the template.
- **A sub-site's sitemap not in the index** → see the `sitemap-check` skill; the
  fix is in this repo's `sitemap.xml`.
- **Broken internal link** → fix the `href`; prefer trailing-slash dir links
  (`/elements/`) to avoid a 301 hop.

## Relationship to other skills

- **`sitemap-check`** — the deep crawlability/robots/sitemap audit. This skill runs
  it as one section; run it standalone when you only care about discoverability.

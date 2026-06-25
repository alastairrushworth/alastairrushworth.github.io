---
name: sitemap-check
description: Audit sitemap.xml and robots.txt discoverability across every sub-component served under alastairrushworth.com (the root user-site plus the separate project sites — /stockscreen, /bootstrapfounders, /elements, /meditation, /inspectdf, /recipes, etc.). Use when reviewing SEO/crawlability, after adding or renaming a sub-site, after editing any sitemap, or to verify the root robots.txt advertises every site's sitemap. Reports missing/unaggregated sitemaps, relative <loc> bugs, redirect hops, and orphaned sub-sites.
---

# sitemap-check

Audits crawl discoverability across the whole domain. The domain serves several
**independent project sites from separate repos under one host**
(`alastairrushworth.com/<site>/`). Because search engines only read `robots.txt`
from the **host root**, a single root `robots.txt` + a single root `sitemap.xml`
(a sitemap *index*) must make every sub-site discoverable. This skill verifies that
holds, and catches the failure modes that come with this layout.

## How to run

```bash
.claude/skills/sitemap-check/check-sitemaps.sh            # audits https://alastairrushworth.com
.claude/skills/sitemap-check/check-sitemaps.sh https://example.com   # any host
```

It audits the **live, deployed** site (that's what crawlers see), so run it
**after** a deploy has gone out. It needs `curl` and `xmllint` (preinstalled on
macOS). Exit code is `0` when there are no failures, `1` otherwise.

The list of sub-components is **discovered live** from the homepage's internal
links and from the sitemap index — nothing is hardcoded, so the audit stays
correct as sites are added or removed.

## What it checks

1. **Root `robots.txt`** — exists (200), has a `Sitemap:` directive, and points at
   `…/sitemap.xml`. (A `robots.txt` at a sub-path like `/elements/robots.txt` is
   **ignored** by crawlers, so the root one is the only one that counts.)
2. **Root `sitemap.xml`** — exists, well-formed, and is a `<sitemapindex>` (so each
   site's own sitemap is aggregated) rather than a lone flat `<urlset>`.
3. **Each child sitemap** named in the index — reachable (200), well-formed, and its
   `<loc>` values are **absolute** and on-host. Relative `<loc>` (e.g. pkgdown's
   default `/articles/…`) are a **FAIL**: Google rejects them.
4. **Per sub-component coverage** — every site linked from the homepage is either
   (a) shipping its own sitemap that's wired into the index, or (b) listed in a
   `urlset` sitemap. Flags sites that ship a sitemap the index doesn't reference
   (deep pages undiscoverable) and sites covered by nothing but a homepage link.
5. **Redirect hygiene** — notes homepage links that cost a 301 hop (e.g. `/elements`
   missing its trailing slash).

## Reading the output

- **FAIL** — breaks discoverability (missing root sitemap/robots, an unreachable or
  un-aggregated child sitemap, relative `<loc>`s). Fix before relying on indexing.
- **WARN** — sub-optimal but not broken (a site reachable only via its homepage link,
  off-host `<loc>`s).
- **·** — informational (redirect hops, declared sitemaps).

## Fixing what it finds

- **Missing root `robots.txt` / `sitemap.xml`** → they live in *this* repo
  (`robots.txt`, `sitemap.xml`, `sitemap-pages.xml`). Add/repair, commit, push.
- **A sub-site ships its own sitemap but it's not in the index** → add a
  `<sitemap><loc>https://alastairrushworth.com/<site>/sitemap.xml</loc></sitemap>`
  entry to `sitemap.xml` in this repo.
- **A sub-site has no sitemap and isn't listed anywhere** → either add its home URL
  to `sitemap-pages.xml`, or give that site its own sitemap and reference it in the
  index. Single-page apps (e.g. stockscreen) are fine in `sitemap-pages.xml`.
- **Relative `<loc>` in a child sitemap** → fix in *that site's* repo (set the
  generator's absolute base URL; for pkgdown set `url:` in `_pkgdown.yml`).

## Before pushing sitemap edits (local quick-check)

The script targets the live host. To sanity-check the XML you're about to commit:

```bash
xmllint --noout sitemap.xml sitemap-pages.xml && echo "well-formed"
```

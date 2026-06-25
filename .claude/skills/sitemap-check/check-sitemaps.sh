#!/usr/bin/env bash
#
# check-sitemaps.sh — audit sitemap & robots.txt health across every
# sub-component served under the site's single host.
#
# The domain hosts several independent project sites (separate repos) under one
# host, e.g. /stockscreen, /bootstrapfounders, /elements, /meditation, /inspectdf.
# Because robots.txt is only honoured at the host ROOT, one root robots.txt + one
# root sitemap index must make all of them discoverable. This script verifies that.
#
# It DISCOVERS sub-components live (from the homepage links + the sitemap index)
# rather than hardcoding them, so it stays correct as sites are added/removed.
#
# Usage:   ./check-sitemaps.sh [BASE_URL]
#          ./check-sitemaps.sh https://alastairrushworth.com   # default
#
# Exit code: 0 if no failures, 1 if any FAIL was reported.

set -uo pipefail

BASE="${1:-https://alastairrushworth.com}"
BASE="${BASE%/}"
TIMEOUT=20

# ---- output helpers -------------------------------------------------------
if [ -t 1 ]; then
  R=$'\033[31m'; G=$'\033[32m'; Y=$'\033[33m'; B=$'\033[34m'; DIM=$'\033[2m'; Z=$'\033[0m'
else
  R=; G=; Y=; B=; DIM=; Z=
fi
FAILS=0; WARNS=0
pass() { printf '  %sPASS%s %s\n' "$G" "$Z" "$1"; }
warn() { printf '  %sWARN%s %s\n' "$Y" "$Z" "$1"; WARNS=$((WARNS+1)); }
fail() { printf '  %sFAIL%s %s\n' "$R" "$Z" "$1"; FAILS=$((FAILS+1)); }
info() { printf '  %s·%s    %s\n' "$DIM" "$Z" "$1"; }
hdr()  { printf '\n%s== %s ==%s\n' "$B" "$1" "$Z"; }

# ---- network helpers ------------------------------------------------------
status()      { curl -s -o /dev/null -m "$TIMEOUT" -w '%{http_code}' "$1"; }
redirect()    { curl -s -o /dev/null -m "$TIMEOUT" -w '%{redirect_url}' "$1"; }
body()        { curl -s -m "$TIMEOUT" "$1"; }
wellformed()  { printf '%s' "$1" | xmllint --noout - 2>/dev/null; }
# extract <loc> values (works on minified or pretty XML, ignores namespaces)
locs()        { grep -oE '<loc>[^<]+</loc>' | sed -E 's#</?loc>##g; s/^[[:space:]]+//; s/[[:space:]]+$//'; }

have_xmllint=1; command -v xmllint >/dev/null 2>&1 || have_xmllint=0
[ "$have_xmllint" = 0 ] && warn "xmllint not found — XML well-formedness checks will be skipped"

printf '%ssitemap audit · %s%s\n' "$B" "$BASE" "$Z"

# ===========================================================================
# 1. Root robots.txt
# ===========================================================================
hdr "root robots.txt"
ROBOTS_SITEMAPS=""
rc=$(status "$BASE/robots.txt")
if [ "$rc" != "200" ]; then
  fail "$BASE/robots.txt -> HTTP $rc (crawlers have no robots.txt for the host; sitemap won't be advertised)"
else
  pass "$BASE/robots.txt -> 200"
  robots=$(body "$BASE/robots.txt")
  ROBOTS_SITEMAPS=$(printf '%s\n' "$robots" | grep -iE '^[[:space:]]*Sitemap:' | sed -E 's/^[[:space:]]*[Ss]itemap:[[:space:]]*//')
  if [ -z "$ROBOTS_SITEMAPS" ]; then
    fail "robots.txt has no 'Sitemap:' directive — sub-site sitemaps are not advertised to crawlers"
  else
    while IFS= read -r sm; do [ -n "$sm" ] && info "declares Sitemap: $sm"; done <<EOF
$ROBOTS_SITEMAPS
EOF
    printf '%s\n' "$ROBOTS_SITEMAPS" | grep -qF "$BASE/sitemap.xml" \
      && pass "robots.txt points at the root sitemap index" \
      || warn "robots.txt does not list $BASE/sitemap.xml (the index) — double-check the path"
  fi
fi

# ===========================================================================
# 2. Root sitemap index + child sitemaps
# ===========================================================================
hdr "root sitemap.xml"
CHILD_SITEMAPS=""   # newline list of child sitemap URLs declared in the index
COVERED_URLS=""     # newline list of every page <loc> found across all sitemaps
sc=$(status "$BASE/sitemap.xml")
if [ "$sc" != "200" ]; then
  fail "$BASE/sitemap.xml -> HTTP $sc (no root sitemap)"
else
  pass "$BASE/sitemap.xml -> 200"
  root_xml=$(body "$BASE/sitemap.xml")
  if [ "$have_xmllint" = 1 ] && ! wellformed "$root_xml"; then
    fail "root sitemap.xml is not well-formed XML"
  fi
  if printf '%s' "$root_xml" | grep -qi '<sitemapindex'; then
    info "type: sitemap index"
    CHILD_SITEMAPS=$(printf '%s' "$root_xml" | locs)
    n=$(printf '%s\n' "$CHILD_SITEMAPS" | grep -c .)
    pass "index references $n child sitemap(s)"
  elif printf '%s' "$root_xml" | grep -qi '<urlset'; then
    info "type: flat urlset (no child sitemaps — sub-sites' own sitemaps are NOT aggregated)"
    COVERED_URLS=$(printf '%s' "$root_xml" | locs)
  else
    fail "root sitemap.xml is neither a <sitemapindex> nor a <urlset>"
  fi
fi

# validate each child sitemap declared by the index
if [ -n "$CHILD_SITEMAPS" ]; then
  hdr "child sitemaps"
  while IFS= read -r cs; do
    [ -n "$cs" ] || continue
    cc=$(status "$cs")
    if [ "$cc" != "200" ]; then
      fail "$cs -> HTTP $cc (referenced by the index but unreachable)"
      continue
    fi
    cxml=$(body "$cs")
    if [ "$have_xmllint" = 1 ] && ! wellformed "$cxml"; then
      fail "$cs -> not well-formed XML"; continue
    fi
    child_locs=$(printf '%s' "$cxml" | locs)
    count=$(printf '%s\n' "$child_locs" | grep -c .)
    # <loc> must be absolute, fully-qualified URLs; relative locs are rejected by Google
    rel=$(printf '%s\n' "$child_locs" | grep -vE '^[a-zA-Z]+://' | grep -c . || true)
    # cross-host locs (not under BASE) are a red flag for a single-host sitemap
    foreign=$(printf '%s\n' "$child_locs" | grep -E '^[a-zA-Z]+://' | grep -vF "$BASE" | grep -c . || true)
    if [ "$rel" -gt 0 ]; then
      fail "$cs -> $count URLs, but $rel use RELATIVE <loc> (Google rejects these; set an absolute base URL in the generator)"
    elif [ "$foreign" -gt 0 ]; then
      warn "$cs -> $count URLs, $foreign point off-host (not under $BASE)"
    else
      pass "$cs -> 200, well-formed, $count absolute URL(s)"
    fi
    COVERED_URLS=$(printf '%s\n%s' "$COVERED_URLS" "$child_locs")
  done <<EOF
$CHILD_SITEMAPS
EOF
fi

# ===========================================================================
# 3. Discover sub-components from the live homepage & cross-check coverage
# ===========================================================================
hdr "sub-component coverage"
home=$(body "$BASE/")
# Discover internal sub-components = first path segment of every internal link on
# the homepage. Handles root-relative (/seg/), absolute same-host (BASE/seg/) and
# relative (seg/) hrefs; drops off-host links, anchors, mailto/tel and file links.
segs=$(printf '%s' "$home" \
  | grep -oE 'href="[^"]+"' \
  | sed -E 's#^href="##; s#"$##' \
  | sed -E "s#^$BASE/?##" \
  | grep -vE '://' \
  | grep -vE '^(#|mailto:|tel:|\?)' \
  | sed -E 's#^/##; s#[/?#].*$##' \
  | grep -vE '^$' \
  | grep -vE '\.' \
  | sort -u)

if [ -z "$segs" ]; then
  warn "no internal sub-component links found on the homepage"
fi

# normalise covered URLs for matching (strip trailing slash)
covered_norm=$(printf '%s\n' "$COVERED_URLS" | sed -E 's#/$##' | sort -u)
child_norm=$(printf '%s\n' "$CHILD_SITEMAPS" | sort -u)

while IFS= read -r seg; do
  [ -n "$seg" ] || continue
  home_url="$BASE/$seg/"
  own_sm_status=$(status "$BASE/$seg/sitemap.xml")
  in_index=0
  printf '%s\n' "$child_norm" | grep -qF "$BASE/$seg/sitemap.xml" && in_index=1
  in_urlset=0
  printf '%s\n' "$covered_norm" | grep -qxF "$BASE/$seg" && in_urlset=1

  # leading status of the sub-site itself
  hstat=$(status "$home_url")
  label="$seg ($home_url -> $hstat)"

  if [ "$own_sm_status" = "200" ] && [ "$in_index" = 1 ]; then
    pass "$label · own sitemap wired into the index"
  elif [ "$own_sm_status" = "200" ] && [ "$in_index" = 0 ]; then
    fail "$label · ships /$seg/sitemap.xml but it is NOT in the root index — its deep pages are undiscoverable. Add <loc>$BASE/$seg/sitemap.xml</loc> to sitemap.xml"
  elif [ "$own_sm_status" != "200" ] && [ "$in_urlset" = 1 ]; then
    pass "$label · no own sitemap, but listed in a urlset sitemap"
  else
    warn "$label · no sitemap of its own and not listed in any sitemap — only crawlable via the homepage link. Either add $home_url to a urlset sitemap, or give /$seg/ its own sitemap and reference it in the index"
  fi

  # redirect hygiene: the homepage link should not cost a 301 hop
  if printf '%s' "$home" | grep -qE 'href="(/'"$seg"'|'"$BASE"'/'"$seg"')"'; then
    rstat=$(status "$BASE/$seg")
    if [ "$rstat" = "301" ] || [ "$rstat" = "302" ]; then
      info "$seg: homepage links /$seg (no trailing slash) -> $rstat redirect; link /$seg/ to skip the hop"
    fi
  fi
done <<EOF
$segs
EOF

# ===========================================================================
# Summary
# ===========================================================================
hdr "summary"
printf '  %s%d fail%s · %s%d warn%s\n' "$R" "$FAILS" "$Z" "$Y" "$WARNS" "$Z"
[ "$FAILS" -eq 0 ] && exit 0 || exit 1

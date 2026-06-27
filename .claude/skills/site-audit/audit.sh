#!/usr/bin/env bash
#
# audit.sh — one-stop deep audit of the site across five dimensions:
#   security/vulns · SEO · accessibility · best-practice · code/link issues
#
# It checks TWO surfaces:
#   • the LOCAL source files in this repo (what you edit & fix) — meta tags,
#     a11y attributes, secrets, SRI, duplicate IDs, HTML validity
#   • the LIVE deployed host (what users & crawlers actually get) — TLS,
#     response headers, redirect hygiene, link resolution, page weight
#
# Crawlability (sitemap.xml / robots.txt) is audited in DEPTH by the sibling
# `sitemap-check` skill; this script runs it as one section so the audit is
# genuinely one-stop, and does not otherwise duplicate it.
#
# Usage:   ./audit.sh [BASE_URL] [--offline]
#          ./audit.sh https://alastairrushworth.com          # default host
#          ./audit.sh --offline                              # source-only, no network
#
# Optional tools used when present (degrades gracefully if absent):
#   xmllint (HTML well-formedness) · tidy (richer HTML validation) ·
#   python3 (WCAG colour-contrast)
#
# Exit code: 0 if no FAILs, 1 otherwise.

set -uo pipefail

# ---- args -----------------------------------------------------------------
BASE="https://alastairrushworth.com"
OFFLINE=0
for a in "$@"; do
  case "$a" in
    --offline) OFFLINE=1 ;;
    http://*|https://*) BASE="${a%/}" ;;
    -h|--help) sed -n '2,30p' "$0"; exit 0 ;;
    *) printf 'unknown arg: %s\n' "$a" >&2; exit 2 ;;
  esac
done

TIMEOUT=20
UA="Mozilla/5.0 (compatible; site-audit/1.0; +https://alastairrushworth.com)"
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
ROOT=$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null) || ROOT=$(cd "$SCRIPT_DIR/../../.." && pwd)

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
status()   { curl -s -o /dev/null -m "$TIMEOUT" -A "$UA" -w '%{http_code}' "$1"; }
headers()  { curl -sI -m "$TIMEOUT" -A "$UA" "$1"; }
body()     { curl -s -m "$TIMEOUT" -A "$UA" "$1"; }
redirect() { curl -s -o /dev/null -m "$TIMEOUT" -A "$UA" -w '%{redirect_url}' "$1"; }
hdr_val()  { printf '%s\n' "$1" | grep -iE "^$2:" | head -1 | sed -E "s/^[^:]+:[[:space:]]*//; s/[[:space:]]*$//"; }

have() { command -v "$1" >/dev/null 2>&1; }
have xmllint || warn "xmllint not found — HTML well-formedness checks skipped"

# The macOS-bundled tidy (2006 Apple build) and libxml2's HTML parser predate
# HTML5 and wrongly report semantic elements as invalid. Detect a MODERN tidy
# (>= v5) for real validation; otherwise we filter that noise out of xmllint.
MODERN_TIDY=0
have tidy && tidy --version 2>&1 | grep -qiE 'version (5|[6-9]|[0-9]{2})' && MODERN_TIDY=1
# HTML5 element names that the old parsers falsely call "invalid"
HTML5_EL='header|footer|main|section|article|aside|nav|figure|figcaption|details|summary|mark|time|dialog|picture|source|track|video|audio|canvas|datalist|output|progress|meter|template|slot|wbr|bdi|ruby|data'

# ---- discover local HTML files -------------------------------------------
HTML_FILES=$(cd "$ROOT" && git ls-files '*.html' 2>/dev/null)
[ -n "$HTML_FILES" ] || HTML_FILES=$(cd "$ROOT" && find . -name '*.html' -not -path './.git/*' | sed 's#^\./##')

printf '%ssite audit · %s%s\n' "$B" "$BASE" "$Z"
printf '%srepo: %s%s\n' "$DIM" "$ROOT" "$Z"
[ "$OFFLINE" = 1 ] && printf '%soffline mode — network checks skipped%s\n' "$DIM" "$Z"

# ===========================================================================
# 1. SEO — on-page (local source)
# ===========================================================================
hdr "SEO · on-page meta (source)"
while IFS= read -r f; do
  [ -n "$f" ] || continue
  p="$ROOT/$f"
  raw=$(cat "$p")

  title=$(printf '%s' "$raw" | grep -oiE '<title>[^<]*</title>' | head -1 | sed -E 's#</?title>##gi')
  if [ -z "$title" ]; then
    fail "$f · no <title>"
  else
    n=${#title}
    if [ "$n" -lt 10 ] || [ "$n" -gt 60 ]; then
      warn "$f · <title> is $n chars (aim 10–60): \"$title\""
    else
      pass "$f · <title> ok ($n chars)"
    fi
  fi

  desc=$(printf '%s' "$raw" | grep -oiE '<meta[^>]+name="description"[^>]*>' | head -1 \
         | grep -oiE 'content="[^"]*"' | sed -E 's/^content="//I; s/"$//')
  if [ -z "$desc" ]; then
    warn "$f · no <meta name=\"description\">"
  else
    n=${#desc}
    if [ "$n" -lt 50 ] || [ "$n" -gt 160 ]; then
      warn "$f · meta description is $n chars (aim 50–160)"
    else
      pass "$f · meta description ok ($n chars)"
    fi
  fi

  printf '%s' "$raw" | grep -qiE '<link[^>]+rel="canonical"' \
    && pass "$f · canonical link present" \
    || warn "$f · no <link rel=\"canonical\"> — duplicate-URL risk"

  # Open Graph completeness
  missing_og=""
  for og in og:title og:description og:url og:type; do
    printf '%s' "$raw" | grep -qiE "property=\"$og\"" || missing_og="$missing_og $og"
  done
  [ -z "$missing_og" ] && pass "$f · core Open Graph tags present" \
                       || warn "$f · missing Open Graph:$missing_og"
  printf '%s' "$raw" | grep -qiE 'property="og:image"' \
    || info "$f · no og:image — social shares render without a preview image"

  # Single H1
  h1=$(printf '%s' "$raw" | grep -oiE '<h1[ >]' | grep -c . || true)
  if [ "$h1" -eq 0 ]; then warn "$f · no <h1>"
  elif [ "$h1" -gt 1 ]; then warn "$f · $h1 <h1> elements (prefer exactly one)"
  else pass "$f · exactly one <h1>"; fi
done <<EOF
$HTML_FILES
EOF

# ===========================================================================
# 2. Accessibility (local source)
# ===========================================================================
hdr "accessibility (source)"
while IFS= read -r f; do
  [ -n "$f" ] || continue
  p="$ROOT/$f"
  raw=$(cat "$p")

  printf '%s' "$raw" | grep -qiE '<html[^>]+lang=' \
    && pass "$f · <html lang> set" \
    || fail "$f · <html> has no lang attribute (screen readers can't pick a voice)"

  # viewport present, and not blocking zoom
  vp=$(printf '%s' "$raw" | grep -oiE '<meta[^>]+name="viewport"[^>]*>' | head -1)
  if [ -z "$vp" ]; then
    warn "$f · no viewport meta — mobile rendering will be off"
  elif printf '%s' "$vp" | grep -qiE 'user-scalable=no|maximum-scale=1'; then
    fail "$f · viewport disables zoom (user-scalable=no / maximum-scale=1) — a11y violation"
  else
    pass "$f · viewport ok and zoom not blocked"
  fi

  # images without alt
  noalt=$(printf '%s' "$raw" | grep -oiE '<img[^>]*>' | grep -ivE 'alt=' | grep -c . || true)
  imgs=$(printf '%s' "$raw" | grep -oiE '<img[^>]*>' | grep -c . || true)
  if [ "$imgs" -eq 0 ]; then info "$f · no <img> elements"
  elif [ "$noalt" -gt 0 ]; then fail "$f · $noalt of $imgs <img> have no alt attribute"
  else pass "$f · all $imgs <img> have alt"; fi

  # generic / empty link text
  generic=$(printf '%s' "$raw" | grep -oiE '<a[^>]*>[^<]*</a>' \
            | grep -iE '>[[:space:]]*(click here|here|read more|link|this)[[:space:]]*<' | grep -c . || true)
  [ "$generic" -gt 0 ] && warn "$f · $generic link(s) with non-descriptive text (\"click here\"/\"here\"/…)" \
                       || pass "$f · no obviously non-descriptive link text"

  # form inputs without an associated label / aria-label
  inputs=$(printf '%s' "$raw" | grep -oiE '<input[^>]*>' | grep -ivE 'type="(hidden|submit|button)"' | grep -c . || true)
  if [ "$inputs" -gt 0 ]; then
    unlabelled=$(printf '%s' "$raw" | grep -oiE '<input[^>]*>' \
                 | grep -ivE 'type="(hidden|submit|button)"' \
                 | grep -ivE 'aria-label|aria-labelledby|id=' | grep -c . || true)
    [ "$unlabelled" -gt 0 ] && warn "$f · $unlabelled input(s) may lack a label (no id/aria-label)" \
                            || pass "$f · inputs appear labelled"
  fi

  # heading order jumps (e.g. h1 -> h3)
  levels=$(printf '%s' "$raw" | grep -oiE '<h[1-6][ >]' | sed -E 's/.*<h([1-6]).*/\1/')
  prev=0; jump=0
  while IFS= read -r lv; do
    [ -n "$lv" ] || continue
    if [ "$prev" -ne 0 ] && [ "$lv" -gt $((prev+1)) ]; then jump=1; fi
    prev=$lv
  done <<EOL
$levels
EOL
  [ "$jump" = 1 ] && warn "$f · heading levels skip a step somewhere (e.g. h1→h3) — fix hierarchy" \
                  || pass "$f · heading hierarchy has no skipped levels"
done <<EOF
$HTML_FILES
EOF

# colour contrast (python3, approximate — assumes :root --bg as the backdrop)
if have python3; then
  hdr "accessibility · colour contrast (source, approximate)"
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    # python emits "STATUS<TAB>message"; bash routes through the counters so the
    # summary total and exit code stay correct.
    while IFS="$(printf '\t')" read -r tag msg; do
      [ -n "$tag" ] || continue
      case "$tag" in
        PASS) pass "$msg" ;;
        WARN) warn "$msg" ;;
        FAIL) fail "$msg" ;;
      esac
    done <<EOL
$(python3 - "$ROOT/$f" "$f" <<'PY'
import re, sys
path, label = sys.argv[1], sys.argv[2]
css = open(path, encoding="utf-8", errors="replace").read()
m = re.search(r":root\s*\{([^}]*)\}", css, re.S)
if not m:
    sys.exit(0)
vars = dict(re.findall(r"--([\w-]+)\s*:\s*(#[0-9a-fA-F]{3,6})", m.group(1)))
bg = vars.get("bg")
if not bg:
    sys.exit(0)
# split CSS into (selector, body) rules so we can see HOW each token is used
rules = re.findall(r"([^{}]+)\{([^{}]*)\}", css)
DECOR = ("::before", "::after", "::marker", "::placeholder", "::selection")
def rgb(h):
    h = h.lstrip("#")
    if len(h) == 3: h = "".join(c*2 for c in h)
    return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))
def lin(c):
    c /= 255
    return c/12.92 if c <= 0.03928 else ((c+0.055)/1.055)**2.4
def lum(h):
    r, g, b = (lin(x) for x in rgb(h))
    return 0.2126*r + 0.7152*g + 0.0722*b
def ratio(a, b):
    la, lb = lum(a)+0.05, lum(b)+0.05
    return round(max(la, lb)/min(la, lb), 2)
def text_selectors(token):
    # selectors that set this token as a TEXT colour (color: var(--token))
    pat = re.compile(r"color\s*:\s*var\(\s*--%s\s*\)" % re.escape(token))
    return [sel.strip() for sel, body in rules if pat.search(body)]
for name, col in sorted(vars.items()):
    if name in ("bg", "line"):
        continue
    cr = ratio(col, bg)
    if cr >= 4.5:
        print("PASS\t%s · --%s %s on --bg %s = %s:1" % (label, name, col, bg, cr))
        continue
    sels = text_selectors(name)
    real = [s for s in sels if not any(d in s for d in DECOR)]
    if not real:
        # token is below AA but only ever paints decorative glyphs / markers
        # (or no text at all) — WCAG exempts purely decorative content
        why = "not used as a text colour" if not sels else "decorative-only: " + ", ".join(sels[:3])
        print("PASS\t%s · --%s %s = %s:1 — WCAG-exempt (%s)" % (label, name, col, cr, why))
    else:
        tag = "WARN" if cr >= 3.0 else "FAIL"
        note = "below 4.5:1 AA" + ("" if cr >= 3.0 else "; below 3:1 even for large/UI text")
        print("%s\t%s · --%s %s = %s:1 on real text [%s] (%s)"
              % (tag, label, name, col, cr, ", ".join(real[:3]), note))
PY
)
EOL
  done <<EOF
$HTML_FILES
EOF
  info "contrast is approximate (assumes --bg backdrop); decorative-only text is exempt — confirm real fg/bg pairings by eye"
fi

# ===========================================================================
# 3. Security / vulnerability (local source)
# ===========================================================================
hdr "security · source"
while IFS= read -r f; do
  [ -n "$f" ] || continue
  p="$ROOT/$f"
  raw=$(cat "$p")

  # reverse tabnabbing: target=_blank without rel noopener
  while IFS= read -r tag; do
    [ -n "$tag" ] || continue
    if ! printf '%s' "$tag" | grep -qiE 'rel="[^"]*noopener'; then
      url=$(printf '%s' "$tag" | grep -oiE 'href="[^"]*"' | head -1)
      fail "$f · target=_blank without rel=\"noopener\" → reverse-tabnabbing ($url)"
    fi
  done <<EOL
$(printf '%s' "$raw" | grep -oiE '<a[^>]*target="_blank"[^>]*>')
EOL

  # mixed content: http:// (not https) resource references
  mixed=$(printf '%s' "$raw" | grep -oiE '(src|href)="http://[^"]*"' | grep -c . || true)
  [ "$mixed" -gt 0 ] && fail "$f · $mixed insecure http:// resource reference(s) — mixed content" \
                     || pass "$f · no insecure http:// resource references"

  # external scripts/styles without Subresource Integrity
  while IFS= read -r tag; do
    [ -n "$tag" ] || continue
    printf '%s' "$tag" | grep -qiE 'integrity=' || \
      warn "$f · external resource without SRI (integrity=): $(printf '%s' "$tag" | cut -c1-90)"
  done <<EOL
$(printf '%s' "$raw" | grep -oiE '<(script|link)[^>]+(src|href)="https?://[^"]*"[^>]*>' | grep -viE "$BASE|alastairrushworth")
EOL

  # inline event handlers (CSP-hostile)
  inln=$(printf '%s' "$raw" | grep -oiE ' on[a-z]+="' | grep -c . || true)
  [ "$inln" -gt 0 ] && info "$f · $inln inline on*= event handler(s) — would break under a strict CSP" || true
done <<EOF
$HTML_FILES
EOF

# secret scan across all tracked files
hdr "security · secret scan (tracked files)"
SECRET_RE='AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----|gh[pousr]_[A-Za-z0-9]{20,}|xox[baprs]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z_-]{20,}|sk-[A-Za-z0-9]{20,}|(secret|api[_-]?key|access[_-]?token|password)["'"'"' :=]+[A-Za-z0-9/_+-]{16,}'
hits=$(cd "$ROOT" && git grep -nIiE "$SECRET_RE" -- ':!.claude/skills/site-audit/*' 2>/dev/null)
if [ -n "$hits" ]; then
  fail "potential secrets / credentials found — verify each (false positives possible):"
  printf '%s\n' "$hits" | head -20 | while IFS= read -r l; do info "$l"; done
else
  pass "no obvious secrets/API keys/private keys in tracked files"
fi

# ===========================================================================
# 4. Code quality (local source)
# ===========================================================================
hdr "code quality (source)"
while IFS= read -r f; do
  [ -n "$f" ] || continue
  p="$ROOT/$f"
  raw=$(cat "$p")

  # doctype + charset
  printf '%s' "$raw" | grep -qiE '<!doctype html>' && pass "$f · has <!doctype html>" \
                                                    || warn "$f · missing <!doctype html>"
  printf '%s' "$raw" | grep -qiE '<meta[^>]+charset=' && pass "$f · charset declared" \
                                                       || warn "$f · no charset meta"

  # duplicate ids
  dups=$(printf '%s' "$raw" | grep -oiE 'id="[^"]+"' | sed -E 's/id="([^"]+)"/\1/I' | sort | uniq -d)
  [ -n "$dups" ] && fail "$f · duplicate id(s): $(printf '%s' "$dups" | tr '\n' ' ')" \
                 || pass "$f · no duplicate ids"

  # HTML validity. Prefer a modern tidy; else xmllint with HTML5-vocabulary
  # false-positives filtered out (old parsers reject <header>/<main>/… etc.).
  if [ "$MODERN_TIDY" = 1 ]; then
    errs=$(tidy -q -e --show-warnings no "$p" 2>&1 | grep -cE 'Error:' || true)
    [ "${errs:-0}" -gt 0 ] && warn "$f · tidy reports $errs HTML error(s) — run: tidy -q -e \"$f\"" \
                           || pass "$f · tidy: no HTML errors"
  elif have xmllint; then
    real=$(xmllint --html --noout "$p" 2>&1 \
           | grep -E 'parser error' \
           | grep -vE "Tag ($HTML5_EL) invalid" | grep -c . || true)
    [ "${real:-0}" -gt 0 ] \
      && warn "$f · $real real HTML parser issue(s) — run: xmllint --html --noout \"$f\" | grep -vE 'Tag ($HTML5_EL) invalid'" \
      || pass "$f · HTML well-formed (HTML5 elements OK; old-parser noise filtered)"
  fi
done <<EOF
$HTML_FILES
EOF

# ===========================================================================
# 5. Live transport & security headers
# ===========================================================================
if [ "$OFFLINE" = 0 ]; then
  hdr "live · TLS & security headers"
  H=$(headers "$BASE/")
  rc=$(printf '%s' "$H" | head -1 | grep -oE '[0-9]{3}' | head -1)
  if [ -z "$rc" ]; then
    fail "$BASE/ unreachable (no response) — is the host live?"
  else
    [ "$rc" = "200" ] && pass "$BASE/ -> 200" || warn "$BASE/ -> HTTP $rc"

    # http -> https upgrade
    http_base=$(printf '%s' "$BASE" | sed 's#^https#http#')
    loc=$(redirect "$http_base/")
    case "$loc" in
      https://*) pass "http:// redirects to $loc" ;;
      "")        warn "http:// did not redirect to https (check 'Enforce HTTPS' is on)" ;;
      *)         warn "http:// redirects to non-https: $loc" ;;
    esac

    # security response headers (GitHub Pages can't set custom headers — see note)
    check_hdr() {
      local name="$1" sev="$2" v
      v=$(hdr_val "$H" "$name")
      if [ -n "$v" ]; then pass "$name: $v"
      elif [ "$sev" = fail ]; then fail "no $name header"
      else warn "no $name header"; fi
    }
    check_hdr "strict-transport-security" warn
    check_hdr "content-security-policy"   warn
    check_hdr "x-content-type-options"    warn
    check_hdr "referrer-policy"           warn
    check_hdr "x-frame-options"           warn
    check_hdr "permissions-policy"        warn
    info "GitHub Pages cannot set custom response headers; the practical CSP/clickjacking"
    info "mitigations are a <meta http-equiv=\"Content-Security-Policy\"> tag + framing guard."
  fi

  # ---- crawlability: defer to the sitemap-check skill ----
  hdr "SEO · crawlability (sitemap-check)"
  if [ -x "$SCRIPT_DIR/../sitemap-check/check-sitemaps.sh" ]; then
    "$SCRIPT_DIR/../sitemap-check/check-sitemaps.sh" "$BASE" || true
  else
    info "sitemap-check skill not found — run it separately for sitemap/robots depth"
  fi

  # ---- live link resolution ----
  hdr "live · link resolution"
  # gather every href/src from local source, classify internal vs external
  LINKS=$(while IFS= read -r f; do [ -n "$f" ] && cat "$ROOT/$f"; done <<EOF
$HTML_FILES
EOF
)
  ALL=$(printf '%s' "$LINKS" | grep -oiE '(href|src)="[^"]+"' | sed -E 's/^(href|src)="//I; s/"$//' \
        | grep -vE '^(#|mailto:|tel:|javascript:|data:)' | sort -u)

  # internal links -> resolve against BASE
  internal=$(printf '%s\n' "$ALL" | grep -vE '://' | grep -vE '^//')
  while IFS= read -r u; do
    [ -n "$u" ] || continue
    case "$u" in
      /*) url="$BASE$u" ;;
      *)  url="$BASE/$u" ;;
    esac
    st=$(status "$url")
    case "$st" in
      200|301|302|308) pass "internal $u -> $st" ;;
      000) warn "internal $u -> no response (timeout)" ;;
      *)   fail "internal $u -> $st" ;;
    esac
  done <<EOF
$internal
EOF

  # external links -> classify (dedupe, cap to be polite)
  external=$(printf '%s\n' "$ALL" | grep -E '^https?://' | grep -viE "$BASE" | sort -u | head -40)
  while IFS= read -r u; do
    [ -n "$u" ] || continue
    st=$(status "$u")
    case "$st" in
      2*|3*)          pass "external $u -> $st" ;;
      401|403|405|429|999) info "external $u -> $st (bot-blocked; verify in a browser)" ;;
      000)            warn "external $u -> no response/timeout" ;;
      *)              fail "external $u -> $st" ;;
    esac
  done <<EOF
$external
EOF

  # ---- page weight / best-practice (homepage) ----
  hdr "live · page weight & best-practice"
  home=$(body "$BASE/")
  bytes=$(printf '%s' "$home" | wc -c | tr -d ' ')
  kb=$((bytes/1024))
  [ "$kb" -lt 100 ] && pass "homepage HTML ${kb}KB (lean)" \
                    || warn "homepage HTML ${kb}KB — consider trimming"
  # true sub-resources only (scripts/styles/images/iframes), not anchor links
  ext_req=$(printf '%s' "$home" | grep -oiE '<(script|link|img|iframe|source)[^>]+(src|href)="https?://[^"]*"' \
            | grep -viE "$BASE|alastairrushworth" | sort -u | grep -c . || true)
  info "external sub-resource elements on homepage (scripts/styles/images/iframes): $ext_req"
  # compression probe: ask for gzip/br explicitly, see what the host returns
  enc=$(curl -sI -m "$TIMEOUT" -A "$UA" -H 'Accept-Encoding: gzip, br' "$BASE/" | grep -i '^content-encoding:' | sed -E 's/^[^:]+:[[:space:]]*//; s/[[:space:]]*$//')
  [ -n "$enc" ] && pass "compression on: content-encoding: $enc" \
                || warn "no compression even when gzip/br requested — larger transfers than necessary"
  cc=$(hdr_val "$H" "cache-control")
  [ -n "$cc" ] && info "cache-control: $cc"
fi

# ===========================================================================
# Summary
# ===========================================================================
hdr "summary"
printf '  %s%d fail%s · %s%d warn%s\n' "$R" "$FAILS" "$Z" "$Y" "$WARNS" "$Z"
printf '  %sreview WARN/FAIL above; the SKILL.md guides turning these into fixes.%s\n' "$DIM" "$Z"
[ "$FAILS" -eq 0 ] && exit 0 || exit 1

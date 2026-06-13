---
name: rss-creator
description: >-
  Create a new RSS feed from the URL of a web page that lacks one. Use this skill
  whenever the user wants to "turn a page into RSS", "make a feed from a site",
  "follow updates of a page that has no RSS", "build a feed of news/notices/press
  releases", or provides a URL asking to generate a feed from it — even if they
  don't explicitly say "RSS". It guides the pre-analysis (check whether a feed
  already exists), the page exploration (static vs JavaScript), field mapping, and
  feed generation with rsspls, integrating it into the repo (feeds.toml + GitHub
  Pages workflow).
compatibility: >-
  Requires: rsspls, scrape, curl, jq, xmllint (or python with ElementTree) and
  the agent-browser skill. Designed for the "rss" repository (feeds.toml +
  bin/build-feeds.py + Pages workflow).
metadata:
  project: rss
---

# RSS creator

This skill builds an RSS feed for a page that doesn't offer one. The goal is not
just "extract data": it is to end up with a `[[feed]]` block in `feeds.toml` that
the repo workflow regenerates and publishes to GitHub Pages every 6 hours.

The guiding principle is **don't do useless work**: first check whether a feed
already exists, then pick the simplest extraction method that works. Most cases
are solved with rsspls alone.

## References

- `refs/rsspls-docs.md` — rsspls documentation (`feeds.toml` config, selectors,
  date handling). Read it when writing/refining a feed block or handling dates in
  non-standard formats.
- `refs/agentskills-specification.md` — skill format specification.
- Fetch and generation pattern: `bin/build-feeds.py` in the repo.

## Phase 0 — Does a feed already exist? (pre-flight, always first)

Generating a feed when the site already publishes one is wasted work and creates
a worse duplicate. Check first. You need the page URL (ask if missing) and the
domain.

**Start the inspection with the agent-browser skill** — open the page in a real
browser and examine it the way a human would looking for a feed. This is the
first contact with the site: it also warms up the static-vs-JavaScript question
for Phase 1.

```bash
agent-browser open "$URL"
# 0a. feed declared in <head> (the canonical place)
agent-browser get count "link[type='application/rss+xml']"
agent-browser get count "link[type='application/atom+xml']"
agent-browser get attr "link[type='application/rss+xml']" href   # if count > 0
# 0b. feed/RSS links in menu, header or footer
agent-browser get count "a[href*='feed'], a[href*='rss'], a[href*='.xml']"
# 0c. platform fingerprint (drives which standard URLs to try)
agent-browser get count "link[href*='wp-content'], script[src*='wp-includes']"  # WordPress
agent-browser get attr "meta[name='generator']" content                         # Joomla/Drupal/etc.
```

Then, based on the platform, probe the **standard endpoints**. This part is an
HTTP-level check (status codes, content-type), so `curl` is the right tool —
agent-browser inspects the page, `curl` probes the URLs:

- WordPress: `/feed/`, `/feed/rss2/`, `?feed=rss2`, and per-section `<section>/feed/`
- Drupal: `/rss.xml`
- Joomla: `?format=feed&type=rss`, `/index.php?format=feed`
- generic: `/atom.xml`, `/index.xml`, `/rss`

**Real validation, not just HTTP 200.** Many sites return `200 text/html` on
`/feed/` even when the feed is disabled. An endpoint is a valid feed only if the
content-type is XML/RSS **and** the body contains `<rss`/`<feed`/`<item`:
```bash
curl -sL -o /tmp/probe "$CANDIDATE" -w "%{content_type}\n"
grep -c -E "<item>|<entry>" /tmp/probe
```

**If you find a valid feed:** tell the user, show the URL, and **suggest not
creating a new one** (just subscribe to the existing one). Proceed only if the
user confirms they still want one (e.g. filtered or cleaned up).

## Phase 1 — Explore the page (static or JavaScript?)

You need to know whether the content is already in the HTML (visible to
`curl`/`scrape`) or arrives via JavaScript (a browser will be needed). The check
is simple: count the candidate elements in the raw HTML and in the rendered DOM.

Use the **agent-browser** skill for the rendered DOM (this is the flow we will
automate):
```bash
agent-browser open "$URL"
agent-browser get count "<candidate-selector>"   # e.g. "article", ".news-list article"
```
and compare with the raw HTML:
```bash
curl -sL -A "Mozilla/5.0" "$URL" | scrape -e "<selector>" | grep -c "<"
```

- **Equal counts and > 0** → static content. Go to level 1 (rsspls).
- **Empty raw, full rendered** → JavaScript content. Level 3.

> Some sites do the opposite: they **block the automated browser** (agent-browser
> shows "The URL you requested has been blocked" or similar) while plain `curl`
> — especially through the proxy — gets the real HTML. If the browser is blocked,
> fall back to analyzing the `curl`/proxy HTML directly. Don't assume "blocked in
> browser" means "needs JavaScript".

> Caution: the browser may show text transformed by CSS (e.g.
> `text-transform: uppercase`). **The HTML source is the truth**, not the visible
> text: rsspls and scrape read the source. Don't manually normalize what is only
> a visual rendering.

## Phase 2 — Map the RSS fields

A useful RSS item has: **title**, **link**, and ideally **date** and
**description**. Identify the CSS (or XPath) selectors relative to each item's
container.

Inspect an item's structure with `scrape`:
```bash
curl -sL -A "Mozilla/5.0" "$URL" -o /tmp/page.html
scrape -b -e "<item-container>" /tmp/page.html | sed 's/></>\n</g' | head -60
```

### Two common list layouts

Almost every "list of news/notices" page is one of these two shapes. Recognizing
which one you're on tells you immediately where the fields live.

**1. Block / card lists** — each item is its own container (`article`, `li`,
`.card`, `.post`). The fields are nested inside it. This is the most common shape
for news, press releases, blog posts.
- `item` = the repeating container — e.g. `.news-list article` (AMAP),
  `.event-card` (RAP)
- `heading`/`link` = a heading link inside it — `h2/h3/h6 a`
- `summary` = a text/excerpt block — `.entry-content`, `.text`
- `date` = a `<time>` (best) or a small date element — `time`, `.event-date`

**2. Table lists** — each item is a table row (`tr`); the fields are cells
(`td`), usually identifiable by a class. Common for registers, "albo pretorio",
tender lists, document archives.
- `item` = the data rows — use the row class to **exclude the header row**, e.g.
  `tr.master-detail-list-line` (Agira), not just `tr`
- `heading` = the subject cell — `.oggetto`, `td.title`
- `link` = a link in an actions/detail cell — `.actions a`
- `date` = a date cell — `.periodo-pubblicazione`, `td.date` (often numeric →
  use `[feed.text_date]`)

If the raw HTML has many repeated `class="...card..."`/`...item...` → block
layout; if it has a `<table>` with many `<tr>` → table layout. A quick probe:
```bash
scrape -e "//table" /tmp/page.html | grep -c "<table"   # >0 hints table layout
grep -oE 'class="[^"]*(card|article|post|item)[^"]*"' /tmp/page.html | sort | uniq -c | sort -rn | head
```

Map, relative to the item container (`feed.config` fields in `feeds.toml`):

| rsspls field | What it is | Note |
|--------------|-----------|------|
| `item` | selector of a single item | e.g. `.news-list article` |
| `heading` | title | usually an `h2/h3/h6 a` |
| `link` | link to the article | the element must have `href`; prefer **absolute** hrefs |
| `summary` | description (optional) | e.g. `.entry-content` |
| `date` | publication date (optional) | a `<time datetime="...">` is ideal |

**Dates.** rsspls parses `<time datetime>` as ISO 8601 by default — when the page
exposes that, just set `date = "time"` and you're done.

For **numeric non-ISO** dates (e.g. `13/06/2026`) use the rsspls table form (see
`refs/rsspls-docs.md`):
```toml
[feed.config.date]
selector = ".date"
type = "Date"            # "Date" without time, "DateTime" with time
format = "[day]/[month]/[year]"
```

For **localized text dates** (month as a word, e.g. Italian `12 giugno 2026`)
rsspls can't help: time-rs only knows English month names. Don't fight it with a
`format` string. Instead leave `date` out of `[feed.config]` and add a
`[feed.text_date]` block — `bin/build-feeds.py` extracts those dates with
`scrape`, parses them with **dateparser** (handles localized months, many
formats, and relative dates like "ieri"/"2 giorni fa"), and injects them as
`<pubDate>`:
```toml
[feed.text_date]
selector = ".event-date"     # one date per item, in item order
# languages = ["it"]         # optional, defaults to ["it"]
```
The selector must return exactly one date element per item, in the same order as
the items (the injection aligns by position, and skips if the counts differ).
If a cell holds two dates (e.g. publication start/end), the first one found is
used.

**Verify the date order — it varies by site and country.** A numeric date like
`11/06/2026` is ambiguous: 11 June (DMY, Italy/Europe) or 6 November (MDY, US).
dateparser will guess, and guess wrong on the ambiguous ones. Don't trust the
default blindly — **check against a date you can disambiguate**: find an item
whose day is > 12 (e.g. `13/06/2026` can only be DMY) and confirm the parsed
`<pubDate>` matches. Then set the order explicitly:
```toml
[feed.text_date]
selector = ".periodo-pubblicazione"
date_order = "DMY"     # default; "MDY" (US), "YMD" (ISO) when the site differs
```
This only affects numeric dates — when the month is a word (`12 giugno 2026`)
there's no ambiguity and `date_order` is ignored.

### Extraction levels (use the simplest one that works)

1. **rsspls alone** — static, regular page: CSS selectors are enough. This is the
   normal case; don't overcomplicate it.
2. **scrape + jq** — irregular structure that rsspls selectors can't isolate well.
   Extract to JSON and reason about / clean the data:
   ```bash
   scrape -je "<selector>" /tmp/page.html | jq '.html.body'
   ```
   (`-j` produces xmltodict JSON: attributes prefixed with `@`, text in `#text`;
   a single element is an object, multiple elements are an array — handle both.)
   This helps to understand/validate the data; the feed is still generated with
   rsspls.
3. **agent-browser** — content rendered only via JavaScript: use the browser to
   read the fields from the rendered DOM and derive the selectors to give rsspls.

## Phase 3 — Add the feed and test it

Add a block to `feeds.toml` (the **real** URL, not proxied — the proxy fetch is
handled by `bin/build-feeds.py`):
```toml
[[feed]]
title = "Readable feed title"
filename = "feed-name.rss"
# enabled = false   # keep in the registry but skip generation

[feed.config]
url = "https://site/section/"
item = "..."
heading = "..."
link = "..."
summary = "..."
date = "time"
```

To **keep a feed registered but stop generating it**, set `enabled = false` on
the feed (default is `true`). The block stays as documentation/anagrafica; the
build skips it. Note the deploy publishes the whole `output/` directory, so a
disabled feed disappears from Pages at the next deploy (its `.rss` is no longer
produced) — re-enable it to bring it back.

Generate and validate locally with the repo script (it downloads via `PROXY_URL`,
rsspls reads from `file://`, restores the links, validates XML + item count):
```bash
uv venv && uv pip install tomli-w        # if the environment is needed
PROXY_URL="<proxy-prefix>?url=" .venv/bin/python bin/build-feeds.py
xmllint --xpath "count(//item)" output/feed-name.rss   # expected: > 0
```

Quality checks before considering it done:
- the feed has **at least one item** and the XML is well-formed;
- the **item links are absolute** (with `file://` relative links break; if the
  page uses relative hrefs, see the note below);
- titles and dates are sensible (dates parsed, not empty).

> **Relative links:** rsspls resolves relative links against the fetch URL. With
> the `file://` flow the base becomes the local file and relative links break. If
> the site uses relative hrefs, flag it: a "absolutize" step is needed (rewrite
> the hrefs with the real domain before rsspls).

## Phase 4 — Publish

Commit `feeds.toml`: the `build-feeds.yml` workflow regenerates and publishes to
`https://<user>.github.io/rss/<feed-name>.rss`. Update the feeds table in
`README.md` with the public link.

## Notes on fetching (why the proxy)

Some sites block or corrupt fetches from GitHub Actions IPs (timeout / 415 /
compressed response that rsspls mishandles in CI). For this reason
`bin/build-feeds.py` downloads with `curl` through a proxy (a Cloudflare Worker,
URL in the repo secret `PROXY_URL`) and then hands the HTML to rsspls via
`file://`. Plain `curl` receives uncompressed content and is reliable toward the
proxy. If a site responds well directly, `PROXY_URL` can be left empty.

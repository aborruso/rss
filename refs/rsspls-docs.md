This file is a merged representation of a subset of the codebase, containing specifically included files and files not matching ignore patterns, combined into a single document by Repomix.

# File Summary

## Purpose
This file contains a packed representation of a subset of the repository's contents that is considered the most important context.
It is designed to be easily consumable by AI systems for analysis, code review,
or other automated processes.

## File Format
The content is organized as follows:
1. This summary section
2. Repository information
3. Directory structure
4. Repository files (if enabled)
5. Multiple file entries, each consisting of:
  a. A header with the file path (## File: path/to/file)
  b. The full contents of the file in a code block

## Usage Guidelines
- This file should be treated as read-only. Any changes should be made to the
  original repository files, not this packed version.
- When processing this file, use the file path to distinguish
  between different files in the repository.
- Be aware that this file may contain sensitive information. Handle it with
  the same level of security as you would the original repository.

## Notes
- Some files may have been excluded based on .gitignore rules and Repomix's configuration
- Binary files are not included in this packed representation. Please refer to the Repository Structure section for a complete list of file paths, including binary files
- Only files matching these patterns are included: content/**/*.md
- Files matching these patterns are excluded: themes/**
- Files matching patterns in .gitignore are excluded
- Files matching default ignore patterns are excluded
- Files are sorted by Git change count (files with more changes are at the bottom)

# Directory Structure
```
content/
  news/
    _index.md
    release-0.10.0.md
    release-0.11.2.md
    release-0.12.0.md
    release-0.8.1.md
    release-0.9.0.md
  _index.md
  documentation.md
  install.md
```

# Files

## File: content/news/_index.md
````markdown
+++
title = "News"
description = "News"
sort_by = "date"
paginate_by = 10
weight = 3
+++

[RSS feed](/index.xml)
````

## File: content/news/release-0.10.0.md
````markdown
+++
title = "Version 0.10.0 released"
description = "The 0.10.0 release has been published. RSS Please now optionally supports reading web pages from local files."
date = 2024-08-31T10:25:14+10:00

#[extra]
#updated = 2024-02-20T22:57:15+10:00
+++

_RSS Please is a command line tool that allows you to generate RSS feeds from web pages.
Parts of the page are extracted using CSS selectors and a feed generated from the matching
items. RSS Please runs on Linux, macOS, Windows, BSD, and more._

The 0.10.0 release has been published. RSS Please now optionally supports reading
web pages from local files.

<!-- more -->

## Version 0.10.0

[This release][release] adds a new optional boolean property, `file_urls`, to the
configuration file (default `false`) indicating whether to allow fetching web
pages from `file` URLs. When set to `true`,
[feed.config.url](@/documentation.md#feed-config-url) can be a URL using the
`file` scheme to a local HTML file like:
`file:///home/wmoore/Documents/example.html`.

This feature enables workflows where the HTML is generated locally before
running RSS Please, or fetching the HTML using a different mechanism such as a
[cURL] invocation or headless browser. This latter option might allow
generating RSS feeds from sites that require authentication or JavaScript to
render.

A statically linked binary for ARM64 Linux is also published for this release,
which should run on Raspberry Pis, and other ARM based Linux devices.

- [Full Changelog](https://github.com/wezm/rsspls/compare/0.9.0...0.10.0)
- [Download][release]

If you find `rsspls` useful please consider a one-off or recurring contribution
to support development [on GitHub Sponsors][sponsor].

[release]: https://github.com/wezm/rsspls/releases/tag/0.10.0
[sponsor]: https://github.com/sponsors/wezm
[cURL]: https://curl.se/
````

## File: content/news/release-0.11.2.md
````markdown
+++
title = "Version 0.11.2 released"
description = "The 0.11.2 release has been published. RSS Please can now be configured to disable TLS certificate verification, which is useful for handling self-signed certificates."
date = 2026-01-05T15:19:41+10:00

#[extra]
#updated = 2024-02-20T22:57:15+10:00
+++

_RSS Please is a command line tool that allows you to generate RSS feeds from web pages.
Parts of the page are extracted using CSS selectors and a feed generated from the matching
items. RSS Please runs on Linux, macOS, Windows, BSD, and more._

The 0.11.2 release has been published. RSS Please can now be configured to
disable TLS certificate verification, which is useful for handling self-signed
certificates.

<!-- more -->

## Version 0.11.2

[This release][release] adds a new optional boolean property,
[insecure_disable_certificate_verification](@/documentation.md#insecure-disable-certificate-verification),
to the configuration file (default `false`) indicating whether to disable
verification of TLS certificates.

This setting applies to the HTTP client used by RSS Please, thus it will apply to
every feed in the configuration. It should only be enabled in specific
situations where certificates fail verification due to being self-signed or
missing intermediate certificates.

- [Full Changelog](https://github.com/wezm/rsspls/compare/0.10.0...0.11.2)
- [Download][release]

If you find `rsspls` useful please consider a one-off or recurring contribution
to support development [on GitHub Sponsors][sponsor].

[release]: https://github.com/wezm/rsspls/releases/tag/0.11.2
[sponsor]: https://github.com/sponsors/wezm
````

## File: content/news/release-0.12.0.md
````markdown
+++
title = "Version 0.12.0 released"
description = "The 0.12.0 release has been published. RSS Please now supports per-feed update hooks that are run when a feed is updated."
date = 2026-04-27T12:21:14+10:00

#[extra]
#updated = 2024-02-20T22:57:15+10:00
+++

_RSS Please is a command line tool that allows you to generate RSS feeds from web pages.
Parts of the page are extracted using CSS selectors and a feed generated from the matching
items. RSS Please runs on Linux, macOS, Windows, BSD, and more._

The 0.12.0 release has been published. RSS Please now supports per-feed update hooks that are run
when a feed is updated.

<!-- more -->

## Version 0.12.0

[This release][release] adds a new optional per-feed property,
[post_update_hook](@/documentation.md#feed-post-update-hook),
to the configuration file specifying a command to run when a feed is updated.
The `RSSPLS_FEED_FILE` environment variable is set in the environment of the spawned
command with the absolute path to the feed file that was updated.

- [Full Changelog](https://github.com/wezm/rsspls/compare/0.11.2...0.12.0)
- [Download][release]

If you find `rsspls` useful please consider a one-off or recurring contribution
to support development [on GitHub Sponsors][sponsor].

[release]: https://github.com/wezm/rsspls/releases/tag/0.12.0
[sponsor]: https://github.com/sponsors/wezm
````

## File: content/news/release-0.8.1.md
````markdown
+++
title = "Version 0.8.1 and Website"
date = 2024-03-08T21:30:39+10:00

#[extra]
#updated = 2024-02-20T22:57:15+10:00
+++

The 0.8.1 release has been published and RSS Please now has its own website.

<!-- more -->

## Version 0.8.1

Many thanks to [Lcchy on GitHub][Lcchy] for these new features in [this release][release]:

* Add per feed user-agent option to config file [#27](https://github.com/wezm/rsspls/pull/27)
* Add a media selector to include as RSS enclosure [#29](https://github.com/wezm/rsspls/pull/29)
* Add option to proxy requests [#32](https://github.com/wezm/rsspls/pull/32)
* Recover from item parsing error and continue [#35](https://github.com/wezm/rsspls/pull/35)

[Full Changelog](https://github.com/wezm/rsspls/compare/0.7.1...0.8.1)

If you find `rsspls` useful you can [sponsor me on GitHub][sponsor].

## Website

RSS Please now has it's own website. Of course it has an RSS feed:
<https://rsspls.7bit.org/index.xml>. The website is built with [Zola] and uses
a modified version of the [Juice theme][Juice]. I've moved a lot of the content
that was in the README to the website. This also allowed me to expand on things
like the configuration file.

The source of [the website is also open-source][source]. If you'd like to
update the content or fix an issue contributions are welcome.

[Juice]: https://github.com/huhu/juice
[Lcchy]: https://github.com/Lcchy
[Zola]: https://www.getzola.org/
[release]: https://github.com/wezm/rsspls/releases/tag/0.8.1
[source]: https://forge.wezm.net/wezm/rsspls.7bit.org
[sponsor]: https://github.com/sponsors/wezm
````

## File: content/news/release-0.9.0.md
````markdown
+++
title = "Version 0.9.0 released"
date = 2024-07-08T13:53:46+10:00

#[extra]
#updated = 2024-02-20T22:57:15+10:00
+++

The 0.9.0 release has been published. The summary selector now supports matching
multiple elements, tilde expansion is performed on the output path, and more.

<!-- more -->

## Version 0.9.0

[This release][release] adds support for matching multiple elements in the
`feed.config.summary` selector. These may be specified comma separated like `p,
blockquote`, or as an array like `["p", "blockquote"]`. The array form allows
the order the elements are added to the generated feed to be controlled. See
[the documentation for more details](@/documentation.md#feed-config-summary).

Tilde expansion is now performed on the `output` path in the configuration file. This
allows a path like `~/Documents/rsspls` to be specified in order to output into the
`Documents` folder of the user running `rsspls`.

The page caches will now be invalidated if the configuration is changed. This way
feeds will always be regenerated when the config file is edited. Previously they
would only be regenerated when the source HTML changed.

It's now possible to build `rsspls` using the native TLS library of the
platform instead of `rustls`. This is particularly handy on Windows ARM where
building the `ring` dependency of `rustls` currently [requires having `clang`
installed][ring]. To build with `native-tls` do the following:

    cargo build --release --locked --no-default-features --features native-tls

[Full Changelog](https://github.com/wezm/rsspls/compare/0.8.1...0.9.0)

If you find `rsspls` useful you can [sponsor me on GitHub][sponsor].

[release]: https://github.com/wezm/rsspls/releases/tag/0.9.0
[sponsor]: https://github.com/sponsors/wezm
[ring]: https://github.com/briansmith/ring/blob/7c0024abaf4fd59250c9b79cc41a029aa0ef3497/BUILDING.md
````

## File: content/_index.md
````markdown
+++
title = "RSS Please"
description = "Generate RSS feeds from web pages"
sort_by = "weight"
#paginate_by = 10
+++

<div class="text-center">
  <a href="https://cirrus-ci.com/github/wezm/rsspls">
    <img src="https://api.cirrus-ci.com/github/wezm/rsspls.svg" alt="Build Status"></a>
  <a href="https://crates.io/crates/rsspls">
    <img src="https://img.shields.io/crates/v/rsspls.svg" alt="Version">
  </a>
  <img src="https://img.shields.io/crates/l/rsspls.svg" alt="License">
</div>

<br>

About
-----

`rsspls` generates RSS feeds from web pages using [CSS selectors][selectors] to
extract parts of the page and turn them into a feed. Example use cases:

* Create a feed for a blog that does not have one so that you will know when
  there are new posts.
* Create a feed from the search results on real estate agent's website so that
  you know when there are new listings—without having to check manually all the
  time.
* Create a feed of the upcoming tour dates of your favourite band or DJ.
* Create a feed of the product page for a company, so you know when new
  products are added.

You can subscribe to the generated feeds in your feed reader, either by
referring to them locally or by publishing them on a web server.

<div class="text-center">
<a href="/install/" class="link-button" style="margin: 0.5em 2em">Install</a>
<a href="/documentation/" class="link-button" style="margin: 0.5em 2em">Documentation</a>
</div>

FAQ
---

Frequently anticipated questions:

* _Does `rsspls` require a runtime or dependencies?_<br>
  No. It's implemented in Rust and is a single-file native binary.
* _The screenshot at the top of the page looks like classic Mac OS.
  Does it run on this system?_<br>
  No. The screenshot _is_ from Mac OS 8 but it shows a [ssheven] window
  logged in to a Linux system running `rsspls`.
* _Why did you use a screenshot from Mac OS 8?_<br>
  I didn't want the screenshot to look like it was from any particular
  modern system, so I picked an old one with a great design.

Licence
-------

This project is dual licenced under either of:

- Apache License, Version 2.0 ([LICENSE-APACHE](https://github.com/wezm/rsspls/blob/master/LICENSE-APACHE))
- MIT license ([LICENSE-MIT](https://github.com/wezm/rsspls/blob/master/LICENSE-MIT))

at your option.

Credits
-------

* [RSS feed icon](http://www.feedicons.com/) by The Mozilla Foundation.
* Website theme based on [Juice](https://github.com/huhu/juice) by HuHu with colours by [Di].
* [Fira Sans](https://github.com/hellogreg/firava) variable font by Mozilla and Greg Gibson.

[selectors]: https://developer.mozilla.org/en-US/docs/Learn/CSS/Building_blocks/Selectors
[ssheven]: https://github.com/cy384/ssheven
[Di]: https://didoesdigital.com/
````

## File: content/documentation.md
````markdown
+++
title = "Documentation"
description = "Documentation"
weight = 2
+++

## How it Works

`rsspls` fetches each page specified by the configuration and extracts elements
from the page using [CSS selectors][selectors]. For example elements are matched
to determine the title and content of the feed entry. The generated feeds are
written to an output directory. HTTP caching is used to only update the feed
when the source page changes.

## Supported Platforms

`rsspls` should work on all [platforms supported by the Rust compiler][platforms]
including Linux, macOS, Windows, and BSD. Pre-compiled binaries are available
for common platforms. See [the install page](@/install.md) for details.

## Usage

```
rsspls [OPTIONS] -o OUTPUT_DIR

OPTIONS:
    -h, --help
            Prints this help information

    -c, --config
            Specify the path to the configuration file.
            $XDG_CONFIG_HOME/rsspls/feeds.toml is used if not supplied.

    -o, --output
            Directory to write generated feeds to.

    -V, --version
            Prints version information

FILES:
     ~/$XDG_CONFIG_HOME/rsspls/feeds.toml    rsspls configuration file.
     ~/$XDG_CONFIG_HOME/rsspls               Configuration directory.
     ~/XDG_CACHE_HOME/rsspls                 Cache directory.

     Note: XDG_CONFIG_HOME defaults to ~/.config, XDG_CACHE_HOME
     defaults to ~/.cache.
```

## Configuration

Unless specified via the `--config` command line option `rsspls` reads its
configuration from one of the following paths:

* UNIX-like systems:
  * `$XDG_CONFIG_HOME/rsspls/feeds.toml`
  * `~/.config/rsspls/feeds.toml` if `XDG_CONFIG_HOME` is unset.
* Windows:
  * `C:\Users\You\AppData\Roaming\rsspls\feeds.toml`

The configuration file is in [TOML][toml] format.

The parts of the page to extract for the feed are specified using [CSS
selectors][selectors].

### Annotated Sample Configuration

The sample file below demonstrates all the parts of the configuration.

```toml
# The configuration must start with the [rsspls] section
[rsspls]
# Optional output directory to write the feeds to. If not specified it must be supplied via
# the --output command line option.
output = "/tmp"
# Optional proxy address. If specified, all requests will be routed through it.
# The address needs to be in the format: protocol://ip_address:port
# The supported protocols are: http, https, socks and socks5h.
# It can also be specified as environment variable `http_proxy` or `HTTPS_PROXY`.
# The config file takes precedence, then the env vars in the above order.
# proxy = socks5://10.64.0.1:1080
# Optionally enable reading web pages from local files though file:// URLs.
# file_urls = false
# Disable verifcation of TLS certificates
# insecure_disable_certificate_verification = false

# Next is the array of feeds, each one starts with [[feed]]
[[feed]]
# The title of the channel in the feed
title = "My Great RSS Feed"

# The output filename without the output directory to write this feed to.
# Note: this is a filename only, not a path. It should not contain slashes.
filename = "wezm.rss"

# Optional User-Agent header to be set for the HTTP request.
# user_agent = "Mozilla/5.0"

# Optional update hook
# post_update_hook = ["my-feed-update-hook", "updated"]

# The configuration for the feed
[feed.config]
# The URL of the web page to generate the feed from.
url = "https://www.wezm.net/"

# A CSS selector to select elements on the page that represent items in the feed.
item = "article"

# A CSS selector relative to `item` to an element that will supply the title for the item.
heading = "h3"

# A CSS selector relative to `item` to an element that will supply the link for the item.
# Note: This element must have a `href` attribute.
# Note: If not supplied rsspls will attempt to use the heading selector for link for backwards
#       compatibility with earlier versions. A message will be emitted in this case.
link = "h3 a"

# Optional CSS selector relative to `item` that will supply the content of the RSS item.
summary = ".post-body"

# Optional CSS selector relative to `item` that supplies media content (audio, video, image)
# to be added as an RSS enclosure.
# Note: The media URL must be given by the `src` or `href` attribute of the selected element.
# Note: Currently if the item does not match the media selector then it will be skipped.
# media = "figure img"

# Optional CSS selector relative to `item` that supples the publication date of the RSS item.
date = "time"

# Alternatively for more control `date` can be specified as a table:
# [feed.config.date]
# selector = "time"
# # Optional type of value being parsed.
# # Defaults to DateTime, can also be Date if you're parsing a value without a time.
# type = "Date"
# # format of the date to parse. See the following for the syntax
# # https://time-rs.github.io/book/api/format-description.html
# format = "[day padding:none]/[month padding:none]/[year]" # will parse 1/2/1934 style dates

# A second example feed
[[feed]]
title = "Example Site"
filename = "example.rss"

[feed.config]
url = "https://example.com/"
item = "div"
heading = "a"
```

The first example above (for my blog WezM.net) matches HTML that looks like this:

```html
<section class="posts-section">
  <h2>Recent Posts</h2>

  <article id="garage-door-monitor">
    <h3><a href="https://www.wezm.net/v2/posts/2022/garage-door-monitor/">Monitoring My Garage Door With a Raspberry Pi, Rust, and a 13Mb Linux System</a></h3>
    <div class="post-metadata">
      <div class="date-published">
        <time datetime="2022-04-20T06:38:27+10:00">20 April 2022</time>
      </div>
    </div>

    <div class="post-body">
      <p>I’ve accidentally left our garage door open a few times. To combat this I built
        a monitor that sends an alert via Mattermost when the door has been left open
        for more than 5 minutes. This turned out to be a super fun project. I used
        parts on hand as much as possible, implemented the monitoring application in
        Rust, and then built a stripped down Linux image to run it.
      </p>
    </div>

    <a href="https://www.wezm.net/v2/posts/2022/garage-door-monitor/">Continue Reading →</a>
  </article>

  <article id="monospace-kobo-ereader">
    <!-- another article -->
  </article>

  <!-- more articles -->

  <a href="https://www.wezm.net/v2/posts/">View more posts →</a>
</section>
```

### output

Optional output directory to write the feeds to. If not specified it must be
supplied via the `--output` command line option. Directory will be created if
it does not exist.

Tilde expansion is performed on the path in the config file. This allows you to
refer to the home directory of the user running `rsspls`. For example,
`~/Documents/rsspls` could be used to place the output in your `Documents`
folder.

### proxy

Optional proxy address. If specified, all requests will be routed through it.
The address needs to be in the format: `protocol://ip_address:port`
The supported protocols are: http, https, socks and socks5h.

The proxy for http and https requests can also be specified with the
environment variables `http_proxy` and `HTTPS_PROXY` respectively.
The config file takes precedence over environment variables.

### file\_urls

Since: 0.10.0

Optional boolean value (default `false`) indicating whether to allow fetching web
pages from `file` URLs. When set to `true`, [feed.config.url](#feed-config-url)
can be a URL using the `file` scheme to a local HTML file like:
`file:///home/wmoore/Documents/example.html`. The path must be absolute.

### insecure\_disable\_certificate\_verification

Since: 0.11.0

Optional boolean value (default `false`) indicating whether to disable
verification of TLS certificates. This setting applies to the HTTP client used
by `rsspls`, thus it will apply to every feed in the configuration. It should
only be enabled in specific situations where certificates fail verification due
to being self-signed or missing intermediate certificates.

### feed.title

The title of the channel in the generated feed.

### feed.filename

The output filename to write this feed to. Note: this is a filename only, not a
path. It should not contain slashes. It will be written to the [output](#output)
directory.

### feed.post_update_hook

Since: 0.12.0

An optional array of strings specifying a command to run when the feed is updated.
The `RSSPLS_FEED_FILE` environment variable is set in the environment of the
spawned command with the absolute path to the feed file that was updated. The
command is not run in a shell. To use shell features like redirection and pipes
a shell must be specified explicitly, such as: `sh -c "some | thing > out"`.

#### Example

```
post_update_hook = ["/home/me/scripts/rsspls-hook", "arg1", "arg2"]
```

### feed.user_agent

Since: 0.8.0

Optional string specifying the value of the `User-Agent` header sent when
`rsspls` make are request to the website for this feed.

### feed.config.url

The URL of the web page to generate the feed from. The page at this address
will be fetched processed to turn it into a feed.

### feed.config.item

A CSS selector to select elements on the page that represent items in the feed.
The other CSS selectors match elements inside the elements that this selector
matches.

### feed.config.heading

A CSS selector relative to `item` to an element that will supply the title for
the item in the feed.


### feed.config.link

CSS selector relative to `item` to an element that will supply the
link for the item in the feed.

**Note:** This element must have a `href` attribute.

**Note:** If not supplied `rsspls` will attempt to use the
`feed.config.heading` selector as the `link` element for backwards compatibility
with earlier versions. A warning message will be emitted in this case. It is
recommended to specify the `link` selector explicitly.


### feed.config.summary

Optional CSS selector relative to `item` that will supply the content of the
RSS item. This value may be a single CSS selector, or an array of CSS
selectors.

The CSS selectors may also include a comma separated list of elements to match.
For example: `summary = "p, blockquote"` will match `p` or `blockquote`
elements, adding them to the RSS feed in the order then are encountered in the
HTML document.

The array form of `summary` allows the order of the matched elements to be
controlled, enabling elements to be added to the feed in a different order to
the source HTML document. For example, `summary = ["p", "blockquote"]` causes
`rsspls` to make a pass over the source HTML document, adding `p` elements to
the feed, followed by a pass adding `blockquote` elements to the feed.

### feed.config.date

The optional `date` key in the configuration can be a string  or a table. If it's a
string then it's used as CSS selector relative to `item` to find the element
containing the date and `rsspls` will attempt to automatically parse the value.

If automatic parsing fails you can manually specify the format using the table
form of `date`, which looks like this:

```toml
[feed.config.date]
selector = "time" # required
type = "Date"
format = "[day padding:none]/[month padding:none]/[year]" # will parse 1/2/1934 style dates
```

If the element matched by the `date` selector is a `<time>` element then
`rsspls` will first try to parse the value in the `datetime` attribute if
present. If the attribute is missing or the element is not a `time` element
then `rsspls` will use the supplied format or attempt automatic parsing of the
text content of the element.

#### feed.config.date.selector

CSS selector relative to `item` that supples the publication date of
the RSS item.

#### feed.config.date.type

Optional type of value being parsed. Either `Date` or `DateTime`.

`type` is `Date` when you want to parse just a date. Use `DateTime` if you're
parsing a date and time with the format. Defaults to `DateTime`.

#### feed.config.date.format

Format description using the syntax described on this page:
<https://time-rs.github.io/book/api/format-description.html>
of how to parse the date.

### feed.config.media

Optional CSS selector relative to `item` that supplies media content (audio,
video, image) to be added as an RSS enclosure.

**Note:** The media URL must be given by the `src` or `href` attribute of the
selected element.

**Note:** Currently if the item does not match the media selector then it will
be skipped.

## Hosting, Updating, and Subscribing

In order to have the feeds update you will need to arrange for
`rsspls` to be run periodically. You might do this with [cron], [systemd
timers][timers], or the Windows equivalent.

To subscribe to feeds you can run `rsspls` locally and use a feed reader that
supports local file feeds. Or, more likely it is expected that `rsspls` will be
run on a web server that is serving the directory the feeds are written to.

## Logging

`rsspls` logs messages to `stderr`. Logging can be controlled by the
`RSSPLS_LOG` environment variable. Log level and target module can controlled
according to the [env_logger documentation][env_logger]. For example, to enable
debug logging for `rsspls` you would use:

`RSSPLS_LOG=rsspls=debug`

The supported log levels are:

* `error`
* `warn`
* `info`
* `debug`
* `trace`
* `off` (disable logging)

The default log level is `info`.

## Caveats & Error Handling

`rsspls` just fetches and parses the HTML of the web page you specify. It does
not run JavaScript. If the website is entirely generated by JavaScript (such as
Twitter) then `rsspls` will not work.

If errors are encountered processing the page due to invalid selectors, or
missing elements an error message will be logged. If the error is non-recoverable
`rsspls` will exit with a non-zero exit status.

If an error is encountered processing an item for the feed a warning will by
logged and processing will continue with the next item. `rsspls` will still
exit with success (0) in this case.

## Caching

When websites respond with cache headers `rsspls` will make a conditional
request on subsequent runs and will not regenerate the feed if the server
responds with 304 Not Modified. Cache data is stored in
`$XDG_CACHE_HOME/rsspls`, which defaults to `~/.cache/rsspls` on UNIX-like
systems or `C:\Users\You\AppData\Local\rsspls` on Windows.

[cron]: https://en.wikipedia.org/wiki/Cron
[env_logger]: https://docs.rs/env_logger/latest/env_logger/#enabling-logging
[platforms]: https://doc.rust-lang.org/stable/rustc/platform-support.html
[selectors]: https://developer.mozilla.org/en-US/docs/Learn/CSS/Building_blocks/Selectors
[timers]: https://wiki.archlinux.org/title/Systemd/Timers
[toml]: https://toml.io/
````

## File: content/install.md
````markdown
+++
title = "Install"
description = "Install"
weight = 1
+++

`rsspls` can be installed via one of the following methods:

* [Package Manager](#package-manager)
* [Download Pre-compiled Binary](#download)
* [Build From Source](#build-from-source)

Download
--------

Pre-compiled binaries are available for a number of platforms.
They require no additional dependencies on your computer.

{{ downloads() }}

This will result in the `rsspls` binary in the current directory.

Package Manager
---------------

`rsspls` is packaged in these package managers:

* AUR: [rsspls](https://aur.archlinux.org/packages/rsspls)
* Homebrew: `brew install wezm/taps/rsspls`
* MacPorts: [rsspls](https://ports.macports.org/port/rsspls/summary/)


Build From Source
-----------------

**Minimum Supported Rust Version:** 1.70.0

`rsspls` is implemented in Rust. See the Rust website for [instructions on
installing the toolchain][rustup].

### From Git Checkout or Release Tarball

Build the binary with `cargo build --release --locked`. The binary will be in
`target/release/rsspls`.

### From crates.io

`cargo install rsspls`

[rustup]: https://www.rust-lang.org/tools/install
````

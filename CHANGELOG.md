# Changelog

## Unreleased

### Change

* **Refine gem packaging and release metadata** <br>
  Tighten the packaged file list to runtime assets and application code,
  and refresh the gem summary and description to position Relay as a
  self-hostable LLM environment you can get running in under 2 minutes.

### Fix

* **Compile the dark theme into `application.css`** <br>
  Include the dark theme in the main stylesheet and remove the dead
  `/themes/*` runtime path so packaged gem installs no longer depend on
  source CSS files under `app/assets`.

## v0.1.0

First stable release.

### Change

* **Load tools during boot through `Relay.reload`** <br>
  Call `Relay.reload` from app boot so Relay registers tools before the
  first request, instead of waiting for a later reload pass.

* **Load user tools from `~/.relay/tools`** <br>
  Extend `Relay.reload` to load tools from both `app/tools/*.rb` and
  `~/.relay/tools/*.rb`, so user-installed tools participate in the same
  registration flow as built-in tools.

### Fix

* **Warn and continue on tool load failures** <br>
  Rescue tool load errors during `Relay.reload`, print a warning with the
  exception and backtrace, and continue loading the remaining tool files
  instead of aborting the full reload pass.

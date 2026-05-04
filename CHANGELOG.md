# Changelog

## Unreleased

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

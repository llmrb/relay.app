# Changelog

## Unreleased

## v0.5.0

Model catalog workflow release.

### Change

* **Add `relay download-models`** <br>
  Introduce a dedicated command for downloading provider model catalogs,
  expose it through `bin/relay`, and have `relay setup` call it after
  configuration so first-time installs still populate model records.

## v0.4.0

Gem startup and setup reliability release.

### Fix

* **Start Falcon from the bundled app root** <br>
  Change `relay start` to run from `Relay.root` so Falcon resolves the
  gem's bundled `config.ru` instead of looking in the user's current
  working directory.

* **Ship `db/config.yml` in the packaged gem** <br>
  Include the database config file in `spec.files` so `relay setup` and
  other boot paths can initialize Sequel successfully after gem
  installation.

## v0.3.0

Gem packaging reliability release.

### Fix

* **Ship `app/init.rb` in the packaged gem** <br>
  Include the top-level app boot file in `spec.files` so `relay bootstrap`
  and other libexec commands can require `app/init` successfully after gem
  installation.

## v0.2.0

Gem packaging and installation release.

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

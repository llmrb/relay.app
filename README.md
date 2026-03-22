## About

Relay is an interactive [llm.rb](https://github.com/llmrb/llm.rb#readme)
application built with HTMX, Roda, Falcon, and WebSockets. It serves
as both a demo of [llm.rb](https://github.com/llmrb/llm.rb#readme) and
an example of a Ruby-first architecture that keeps JavaScript light
while still supporting background workers and a database-backed app.

Relay serves as a reference implementation for building real-time,
tool-enabled LLM applications with llm.rb in a production-style
environment.

## Screencast

[![Watch the Relay screencast](https://img.youtube.com/vi/Zav-aeop97k/maxresdefault.jpg)](https://www.youtube.com/watch?v=Zav-aeop97k)

## Features

### Application

- 🌊 Streaming chat over WebSockets
- 🛠️ Custom tool support via [app/tools/](app/tools)
- 🖼️ Sample image-generation tool in [create_image.rb](./app/tools/create_image.rb)
- 📚 Sample knowledge tool in [relay_knowledge.rb](./app/tools/relay_knowledge.rb)
- 🎵 Sample jukebox tool in [juke_box.rb](./app/tools/juke_box.rb)

The example tools show two useful patterns: delegating work to external
providers, and exposing documentation-backed knowledge to the model
through a tool.

The jukebox tool gives the LLM a small built-in playlist. It can use
`juke_box.rb` to pick a track and show a playable embed in the chat UI.

### Architecture

- ⚙️ Rack application built with Falcon, Roda, and async-websocket
- 🗃️ Sequel with built-in migrations
- 🧵 Sidekiq workers for background jobs
- 🧰 Built-in task monitor that supervises the full dev environment: web, workers, assets
- 🗂️  Session support through Roda's session plugin
- ⚡ In-memory cache support via `Relay.cache`
- 🔐 Automatic `.env` loading during app boot

## Quick start

**Setup**

Redis is required for Sidekiq support.
SQLite is required for database support.

    bundle install
    bundle exec rake db:migrate
    bundle exec rake dev:start

**Secrets**

Set your secrets in `.env`:

```sh
OPENAI_SECRET=...
GOOGLE_SECRET=...
ANTHROPIC_SECRET=...
DEEPSEEK_SECRET=...
XAI_SECRET=...
SESSION_SECRET=
REDIS_URL=
```
## Architecture

**Overview**

The architecture is intentionally simple. HTMX keeps the client light,
while server-rendered HTML keeps the application comfortable for
Ruby-focused developers. Background work is handled with Sidekiq, and
development processes are coordinated by Relay's task monitor.

Some important notes:

* The app boots from `app/init.rb`, which sets up the database,
  autoloading, and application initialization.
* `.env` is loaded automatically during boot when present.
* HTTP routing is handled by Roda, with templates rendered from
  `app/views` and static assets served from `public/`.
* Webpack builds the JavaScript and CSS assets from `app/assets`.

The codebase is organized by responsibility:

- `app/init` contains boot and framework setup
- `app/tools` contains tools
- `app/prompts` contains system prompt
- `app/models` contains Sequel models
- `app/routes` contains route classes and WebSocket handlers
- `app/views` contains HTML templates and partials
- `app/workers` contains Sidekiq workers
- `db/` contains database configuration and migrations
- `tasks/` contains rake tasks for development, assets, and database work
- `lib/relay` contains support code like the task monitor

**Route**

A route is a class that inherits from `Relay::Routes::Base` and
implements `call`. `Base` delegates missing methods to the current
Roda instance, so route classes can use helpers like `view`, `partial`,
`request`, `response`, `session`, and `params`:

```ruby
# app/routes/some_route.rb
module Relay::Routes
  class SomeRoute < Base
    def call
      "hello world"
    end
  end
end

# app/init/router.rb
r.on "some-route" do
  r.is do
    SomeRoute.new(self).call
  end
end
```

**State**

Relay includes session support through Roda's session plugin. This is
useful for lightweight per-user state such as the current provider and
model, which can be rendered directly in views and updated through
normal route handlers.

For shared in-process state, Relay exposes `Relay.cache`, which is
backed by `Relay::Cache::InMemoryCache`. This is useful for small,
ephemeral caches such as model lists that can be reused across routes
without treating them as persistent data.

## Sources

* [GitHub.com](https://github.com/llmrb/relay)
* [GitLab.com](https://gitlab.com/llmrb/relay)
* [Codeberg.org](https://codeberg.org/llmrb/relay)

## License

[BSD Zero Clause](https://choosealicense.com/licenses/0bsd/)
<br>
See [LICENSE](./LICENSE)

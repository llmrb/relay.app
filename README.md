## About

Relay is a developer environment for working with LLMs in real time.
Built with [llm.rb](https://github.com/llmrb/llm.rb#readme), HTMX,
Roda, Falcon, and WebSockets, it gives you a Ruby-first interface for
experimenting with providers, models, tools, MCP servers, streaming
responses, and background jobs.

Relay also serves as a reference implementation for building
production-style, tool-enabled LLM applications with llm.rb while
keeping the frontend light and the architecture Ruby-centric.

## Screencast

[![Watch the Relay screencast](https://img.youtube.com/vi/Jb7LNUYlCf4/maxresdefault.jpg)](https://www.youtube.com/watch?v=Jb7LNUYlCf4)

## Features

### Application

- 🌊 Streaming chat over WebSockets
- 🛠️ Custom tool support via [app/tools/](app/tools)
- 🔌 MCP server support via [app/config/mcp.yml](app/config/mcp.yml)
- 🖼️ Sample image-generation tool in [create_image.rb](./app/tools/create_image.rb)
- 📚 Sample knowledge tool in [relay_knowledge.rb](./app/tools/relay_knowledge.rb)
- 🎵 Sample jukebox tool in [juke_box.rb](./app/tools/juke_box.rb)

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

Relay is easy to start locally. Right now it only requires:

- Ruby
- a web server, via `bundle exec rake dev:start`
- Node.js
- Webpack
- SQLite

The architecture supports more, including Sidekiq and Redis, but those
are optional for the current local setup. The following commands should
get you setup with a local instance of Relay once the requirements mentioned
above are met: 

    bundle install
    bundle exec rake db:setup
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

**Tools**

Relay ships with a small set of built-in tools in [`app/tools/`](app/tools):

- [`create_image.rb`](./app/tools/create_image.rb) generates images
- [`relay_knowledge.rb`](./app/tools/relay_knowledge.rb) exposes project documentation
- [`juke_box.rb`](./app/tools/juke_box.rb) provides a built-in playlist for the chat UI

These tools serve as examples of how to extend Relay's behavior. They
show common patterns such as calling external providers, returning
documentation-backed knowledge, and rendering structured tool output in
the interface.

To add your own behavior, create additional tools under `app/tools/`.
Relay loads registered tools automatically, so new tools become
available to the model alongside the built-in ones.

**MCP**

Relay reads MCP server configuration from `app/config/mcp.yml`.
Use [`app/config/mcp.yml.sample`](app/config/mcp.yml.sample) as the
starting point.

You can add your own stdio MCP servers by appending entries under
`stdio`. Each server entry includes:

- `name`: the display name shown in the UI
- `description`: a short explanation of what the server provides
- `config`: the stdio launch configuration Relay passes to `LLM.mcp`

The `config` object supports:

- `argv`: the command and arguments used to start the MCP server
- `env`: environment variables passed to the process
- `cwd`: optional working directory for the process

Example:

```yml
stdio:
  - name: GitHub
    description: GitHub's MCP server
    config:
      argv: ["github-mcp-server", "stdio"]
      env:
        GITHUB_PERSONAL_ACCESS_TOKEN: <YOUR_TOKEN>
```

Setup:

1. Install the MCP server binary you want to use, for example
   `github-mcp-server`.
2. Copy `app/config/mcp.yml.sample` to `app/config/mcp.yml`.
3. Fill in any required environment variables such as API tokens.
4. Restart Relay.

Once configured, Relay starts the MCP servers for the chat session and
adds their tools to the available tool list.

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

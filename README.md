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
- 🤖 Multiple provider support: OpenAI, Google, Anthropic, DeepSeek, xAI
- 🛠️ Add your own tools to [app/tools/](app/tools)
- 🧪 Sample tools: [create_image.rb](./app/tools/create_image.rb), [relay_knowledge.rb](./app/tools/relay_knowledge.rb), [juke_box.rb](./app/tools/juke_box.rb)
- 🔌 Optional MCP server support via [app/config/mcp.yml.sample](app/config/mcp.yml.sample)
- 🔐 User authentication with session-backed sign-in

### Architecture

- ⚙️ Rack application built with Falcon, Roda, and async-websocket
- 🗃️ Sequel with built-in migrations
- 🧵 Optional Sidekiq workers for background jobs when Redis is configured
- 🧰 Built-in task monitor that supervises the development environment: web, workers, assets
- 🗂️ Session support through Roda's session plugin
- ⚡ In-memory cache support via `Relay.cache`
- 🔐 Automatic `.env` loading during app boot
- 🧭 Zeitwerk autoloading under the `Relay` namespace
- 🛠️ Automatic tool loading from `app/tools/`

## Quick start

**Requirements**

Relay is easy to start locally. Right now it only requires:

- Ruby
- a web server, via `bundle exec rake dev:start`
- Node.js
- Webpack
- SQLite

The architecture supports more, including Sidekiq and Redis, but those
are optional for the current local setup.

**Setup**

The following commands should get you setup with a local instance of Relay
once the requirements mentioned above are met. The `db/seeds.rb` file
creates a default user with email `0x1eef@hardenedbsd.org` and
password `relay`. That account can be used to sign in locally, or
change the seeded values in [`db/seeds.rb`](./db/seeds.rb) to something
else before running `bundle exec rake db:seed`:

    bundle install
    bundle exec rake db:setup
    bundle exec rake db:seed
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

## Customization

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

Relay reads MCP server configuration from `app/config/mcp.yml` when the
file is present. Use [`app/config/mcp.yml.sample`](app/config/mcp.yml.sample)
as the starting point.

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
adds their tools to the available tool list. If `app/config/mcp.yml`
is absent, Relay starts without any MCP servers.

## Architecture

**Overview**

The architecture is intentionally simple. HTMX keeps the client light,
while server-rendered HTML keeps the application comfortable for
Ruby-focused developers. Interactive chat runs over the WebSocket
endpoint at `/api/ws`, and background work can be handled by Sidekiq
when Redis is configured.

Relay boots from `app/init.rb`, which loads environment variables,
connects to the database, configures optional Sidekiq support, sets up
Roda routing, and loads tools from `app/tools/`. Code under `app/` is
autoloaded via Zeitwerk under the `Relay` namespace. Frontend assets are
built from `app/assets` with Webpack, and `rake dev:start` uses Relay's
task monitor to run the web server, asset builds, and workers together
in development.

Session state is useful for lightweight per-user settings such as the
selected provider and model, while shared in-process cached values are
stored in `Relay.cache`.

Some important notes:

* The app boots from `app/init.rb`, which sets up the database,
  autoloading, and application initialization.
* `.env` is loaded automatically during boot when present.
* HTTP routing is handled by Roda, with templates rendered from
  `app/views`.
* Webpack builds the JavaScript and CSS assets from `app/assets`.

The codebase is organized by responsibility:

- `app/init` contains boot and framework setup
- `app/hooks` contains reusable request hooks
- `app/pages` contains full-page renderers
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
`request`, `response`, `session`, and `params`.

Routes also expose `r` as a small alias for `request`, which mirrors the
way Roda route blocks commonly refer to the request object:

```ruby
# app/routes/some_route.rb
module Relay::Routes
  class SomeRoute < Base
    def call
      r.redirect("/some-other-route")
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

**Page**

A page is a class that inherits from `Relay::Pages::Base` and renders a
full page from `app/views/pages`. Like routes, pages delegate missing
methods to the current Roda instance, but they are intended for page
rendering rather than request actions:

```ruby
# app/pages/chat.rb
module Relay::Pages
  class Chat < Base
    prepend Relay::Hooks::RequireUser

    def call
      response["content-type"] = "text/html"
      page("chat", title: "Relay")
    end
  end
end

# app/init/router.rb
r.root do
  Pages::Chat.new(self).call
end
```

**Hooks**

A hook is an ordinary Ruby module, usually stored under `app/hooks`,
that uses `prepend` to act as a hook for page and route objects.
Hooks implement `call` and control request flow similarly to a before
filter: they decide whether to let the request proceed by calling
`super`, or halt the request by returning or redirecting instead.

Hooks are named as verbs that describe the behavior they enforce, such
as `RequireUser`.

Each hook typically defines `call`, performs its setup or guard logic,
and then calls `super` to continue to the next prepended hook or, once
no hooks remain, the underlying page or route:

```ruby
module Relay::Hooks
  module RequireUser
    def call
      @user = Relay::Models::User[session["user_id"]]
      @user.nil? ? r.redirect("/sign-in") : super
    end
  end
end

module Relay::Pages
  class Chat < Base
    prepend Relay::Hooks::RequireUser

    def call
      page("chat", title: "Relay")
    end
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

## Developers

Relay includes a test suite built with `rack-test` and `test-unit` from the Ruby standard library. The tests follow the patterns established in the codebase and focus on HTTP route behavior.

### Setup

Install test dependencies:

```bash
bundle install
```

Run the full test suite:

```bash
rake test
```

### Test Structure

- **`test/setup.rb`** - Shared test setup and Rack::Test bootstrapping
- **`test/routes/`** - Route-specific tests

The `rake test` task loads all files matching `test/**/*_test.rb`.

## Sources

* [GitHub.com](https://github.com/llmrb/relay)
* [GitLab.com](https://gitlab.com/llmrb/relay)
* [Codeberg.org](https://codeberg.org/llmrb/relay)

## License

[BSD Zero Clause](https://choosealicense.com/licenses/0bsd/)
<br>
See [LICENSE](./LICENSE)

## About

Relay is a self-hostable LLM environment for building and trying out AI
apps, workflows, and interface ideas. It gives you one place to work
with providers, models, tools, MCP servers, attachments, saved
contexts, and streaming conversations, and works both as a practical
self-hosted workspace and as a reference app for exploring how AI
products can be put together and extended over time.

## Quick start

If you just want Relay running locally, this is the shortest path.

**Requirements**

- Ruby
- Node.js
- Webpack
- SQLite

**1. Install dependencies**

```sh
bundle install
```

**2. Configure secrets**

Create a `.env` file:

```sh
OPENAI_SECRET=...
GOOGLE_SECRET=...
ANTHROPIC_SECRET=...
DEEPSEEK_SECRET=...
XAI_SECRET=...
SESSION_SECRET=...
REDIS_URL=
```

You only need provider secrets for the providers you plan to use.

**3. Set up the database**

```sh
bundle exec rake db:setup
bundle exec rake db:seed
```

The seed creates a default local user:

- email: `0x1eef@hardenedbsd.org`
- password: `relay`

Change the seeded values in [db/seeds.rb](./db/seeds.rb) first if you
do not want those defaults.

**4. Start Relay**

```sh
bundle exec rake dev:start
```

Then open Relay in your browser and sign in with the seeded account.

During development, Relay enables Zeitwerk reloading and refreshes
autoloaded constants between requests, so changes under `app/` are
picked up without restarting the web server.

## Screencast

[![Watch the Relay screencast](https://img.youtube.com/vi/Jb7LNUYlCf4/maxresdefault.jpg)](https://www.youtube.com/watch?v=x1K4wMeO_QA)

## Why Relay?

Relay is a good fit if you want to:

- self-host an LLM workspace
- connect models to real tools
- use MCP servers from one interface
- switch between providers and models
- study or extend a Ruby-first LLM app

## Features

### Workspace

- Streaming chat over WebSockets with server-rendered updates
- Multiple provider support: OpenAI, Google, Anthropic, DeepSeek, and xAI
- Saved chat contexts with provider-aware switching and new-context creation
- Attachment support for providers that accept local files through `llm.rb`
- Built-in tool support plus automatic loading of custom tools from [app/tools/](app/tools)
- Optional MCP server integration via [app/config/mcp.yml.sample](app/config/mcp.yml.sample)
- Session-backed sign-in and per-user persistent context
- A jukebox sidebar with tool-driven playlist management

### Platform

- Rack application built with Falcon, Roda, and async-websocket
- Sequel models and migrations for application state
- Sidekiq workers for background jobs
- A built-in task monitor for the local development stack: web, workers, and assets
- Session support through Roda's session plugin
- In-memory shared state via `Relay.cache`
- Automatic `.env` loading during boot
- Zeitwerk hot reloading in development

## Cost considerations

Relay supports multiple providers, each with different pricing models.
For cost-conscious users, **DeepSeek** offers an excellent balance of
quality and affordability:

- **DeepSeek** costs approximately **$0.05** to fill a 128K context
  window
- This makes it one of the most cost-effective options for long
  conversations and tool-heavy workflows
- DeepSeek's pricing is significantly lower than comparable models from
  OpenAI, Anthropic, or Google

The only caveat is that DeepSeek can sometimes be slower than other
models to process tool calls. This is fine if you give good
instructions, then go do other things, and come back to DeepSeek
afterwards.

When using Relay for extended sessions or frequent tool usage, DeepSeek
can help keep operational costs minimal while maintaining good
performance.

## Customization

**Tools**

Relay ships with built-in tools in [`app/tools/`](app/tools):

- [`create_image.rb`](./app/tools/create_image.rb) generates images
- [`relay_knowledge.rb`](./app/tools/relay_knowledge.rb) exposes project documentation
- [`juke_box.rb`](./app/tools/juke_box.rb) reads from the built-in playlist
- [`add_song.rb`](./app/tools/add_song.rb) adds songs to the jukebox playlist
- [`remove_song.rb`](./app/tools/remove_song.rb) removes songs from the jukebox playlist
- [`apropos.rb`](./app/tools/apropos.rb) searches FreeBSD man pages with `apropos`

These tools serve as examples of how to extend Relay's behavior. They
show common patterns such as calling external providers, editing local
application data, returning documentation-backed knowledge, invoking
system commands, and rendering structured tool output in the interface.

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

For local or self-hosted Forgejo and Gitea instances, you can use an MCP
server such as [`forgejo-mcp`](https://github.com/Sqcows/forgejo-mcp)
and point it at your local server URL:

```yml
stdio:
  - name: Forgejo
    description: Forgejo/Gitea MCP server
    config:
      argv: ["npx", "@ric_/forgejo-mcp"]
      env:
        FORGEJO_URL: http://localhost:3000
        FORGEJO_TOKEN: <YOUR_TOKEN>
```

Setup:

1. Install the MCP server binary you want to use, for example
   `github-mcp-server` or `npx @ric_/forgejo-mcp`.
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
Ruby-focused developers. Background work is handled with Sidekiq, and
development processes are coordinated by Relay's task monitor.

Some important notes:

* The app boots from `app/init.rb`, which sets up the database,
  autoloading, and application initialization.
* `.env` is loaded automatically during boot when present.
* HTTP routing is handled by Roda, with templates rendered from
  `app/views` and static assets served from `public/`.
* Webpack builds the JavaScript and CSS assets from `app/assets`.
* `bundle exec rake dev:start` runs Relay's local development stack.

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

- **`test/setup.rb`** - Base test setup with Rack::Test integration
- **`test/routes/`** - Route-specific tests

Tests are automatically discovered from files matching `test/**/*_test.rb`.

## Sources

* [GitHub.com](https://github.com/llmrb/relay)
* [GitLab.com](https://gitlab.com/llmrb/relay)
* [Codeberg.org](https://codeberg.org/llmrb/relay)

## License

[BSD Zero Clause](https://choosealicense.com/licenses/0bsd/)
<br>
See [LICENSE](./LICENSE)

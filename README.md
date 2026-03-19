## About

Relay is a small chat app built with [llm.rb](https://github.com/llmrb/llm.rb).
It demonstrates streaming over WebSockets, tool calls, image generation,
provider switching, model selection, and a small Active Record-backed
server. The client lives under `app/client`, and the Rack server lives
under `app/server`. See the [Screencast](#screencast) for a demo.

Enjoy :)

## Screencast

[![Watch the screencast](https://img.youtube.com/vi/fOvAFq7ITiE/maxresdefault.jpg)](https://youtu.be/fOvAFq7ITiE)

Watch the screencast on [YouTube](https://youtu.be/fOvAFq7ITiE).

## Features

- ⚙️ Rack application built with Falcon, Roda, and async-websocket
- 🗃️ Active Record with standalone migrations
- 🌊 Streaming chat over WebSockets
- 🔀 Switch providers: OpenAI, Gemini, Anthropic, xAI and DeepSeek
- 🧠 Switch models: varies by provider
- 🛠️ Add your own tools: see [app/server/tools/](app/server/tools)
- 🖼️ Image generation via [create_image.rb](./app/server/tools/create_image.rb) - requires Gemini, OpenAI or xAI but works with any provider

## Usage

**Secrets**

Set your secrets in `.env`:

```sh
OPENAI_SECRET=...
GEMINI_SECRET=...
ANTHROPIC_SECRET=...
DEEPSEEK_SECRET=...
XAI_SECRET=...
```

**Packages**

Install Ruby gems:

```sh
bundle install
```

Install client packages:

```sh
bundle exec rake npm:i
```

**Database**

Create a migration:

```sh
bundle exec rake db:new_migration name=create_widgets
```

Run migrations:

```sh
bundle exec rake db:migrate
```

Models live in `app/server/models`, and the app boots Active Record from
`db/config.yml`.

The SQLite database files under `db/` are local-only and ignored by git.

**Server Layout**

- `app/server/models` contains Active Record models
- `app/server/routes` contains the Roda-facing endpoints
- `app/server/tools` contains LLM tool classes
- `app/server/router.rb` dispatches `/models` and `/ws`
- `config.ru` serves generated images from `public/g` and boots the router

**Development**

Run the server and webpack dev server in separate shells:

```sh
bundle exec rake dev:server
bundle exec rake dev:client
```

Then open `http://localhost:9293`. The Ruby server on `9292` only
serves `/models`, `/ws`, and generated images from `/g`.

The webpack dev server proxies `/models`, `/ws`, and `/g` back to the
Ruby server, so image generation works in development without building
the client bundle first.

Or run both processes together with Foreman:

```sh
bundle exec foreman start
```

## Sources

* [GitHub.com](https://github.com/llmrb/realtalk)
* [GitLab.com](https://gitlab.com/llmrb/realtalk)
* [Codeberg.org](https://codeberg.org/llmrb/realtalk)

## License

[BSD Zero Clause](https://choosealicense.com/licenses/0bsd/)
<br>
See [LICENSE](./LICENSE)

## About

EasyTalk is a small chat app built with [llm.rb](https://github.com/llmrb/llm.rb).
It demonstrates streaming over WebSockets, tool calls, provider switching, and
model selection in a simple Rack app with a small React frontend. Enjoy :)

## Features

- ⚙️ Rack application built with Falcon and async-websocket
- 🌊 Streaming chat over WebSockets
- 🔀 Switch providers: OpenAI, Gemini, Anthropic, xAI and DeepSeek
- 🧠 Switch models: varies by provider
- 🛠️ Add your own tools: see [app/tools/](app/tools)
- 🖼️ Image generation via [create_image.rb](./app/tools/create_image.rb) - requires Gemini, OpenAI or xAI but works with any provider

## Screencast

<p align="center">
  <a href="https://www.youtube.com/watch?v=FsSn7KuWY8o">
    <img src="https://img.youtube.com/vi/FsSn7KuWY8o/maxresdefault.jpg" alt="Watch the EasyTalk demo on YouTube">
  </a>
</p>

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

Build the frontend:

```sh
bundle exec rake build
```

**Serve**

Start the server:

```sh
bundle exec rake serve
```

## Sources

* [GitHub.com](https://github.com/llmrb/easytalk)
* [GitLab.com](https://gitlab.com/llmrb/easytalk)
* [Codeberg.org](https://codeberg.org/llmrb/easytalk)

## License

[BSD Zero Clause](https://choosealicense.com/licenses/0bsd/)
<br>
See [LICENSE](./LICENSE)

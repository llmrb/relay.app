# Relay

A self-hostable LLM environment you can configure in 2 minutes or less.

## Features

* Install and setup in 2 minutes
* Localize your chats and MCP settings to your user account
* Connect to multiple providers (OpenAI, xAI, Anthropic, Google, DeepSeek, zAI)
* Connect to MCP servers
* Cancel in-flight requests and tool execution cleanly
* Run tools concurrently
* Make it yours: extend and customize with your own tools and system prompt
* Lightweight architecture

## Getting Started

### Install

```sh
gem install relay.app
```

### Setup

Run the interactive setup:

```sh
relay setup
```

This will create the configuration directory at `~/.config/relay/` and guide you
through the initial setup.

### Start

```sh
relay start
```

Visit http://localhost:9292 to access Relay.

## Configuration

Relay stores its configuration, tools, and data in `~/.config/relay/` by default.
You can override this by setting the `RELAY_HOME` environment variable.

### Environment Variables

| Variable | Default | Description |
|---|---|---|
| `RELAY_HOME` | `~/.config/relay` | Relay configuration directory |
| `RELAY_PORT` | `9292` | Web server port |
| `RELAY_HOST` | `0.0.0.0` | Web server host |

## Custom Tools

Add your own tools to `~/.config/relay/tools/`. Each tool is a Ruby file that
defines a class inheriting from `LLM::Tool`:

```ruby
class Shell < LLM::Tool
  name "shell"
  description "Run a shell command"
  parameter :command, String, "The command to run"
  parameter :arguments, Array[String], "The command arguments"
  required %i[command]

  def call(command:, arguments:)
    {ok: system(command, *arguments)}
  end
end
```

## License

BSD Zero Clause

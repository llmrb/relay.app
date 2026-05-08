## About

Relay is a self-hostable LLM web application that can be extended
with your own tools and skills that live in your `${HOME}` directory.

It includes support for DeepSeek, OpenAI, Anthropic, AWS Bedrock, Google, xAI
and zAI out of the box. Ollama and llamacpp support is planned.

It includes MCP server support too - connect Relay to MCP servers,
the default presets include GitHub and Forgejo.

The database is SQLite3, and each user has their own isolated
environment.

It is simple to setup and get started. The application is
distributed as a RubyGem. It has a minimal set of dependencies -
built on Roda, Sequel, Falcon, [llm.rb](https://github.com/llmrb/llm.rb),
HTMX and web sockets.

## How easy is it to setup?

Very easy.

![demo](./demo.gif)

## Getting started

#### Install

Install the gem:

```sh
gem install relay.app
```

Go through interactive setup, start the server, and visit
http://localhost:9292.

```sh
relay setup
relay start
```

## Features

* Setup is fast enough that you can be chatting in a couple of minutes
* Self-host it and keep each user's chats and MCP settings isolated
* Use the model providers you want: DeepSeek, OpenAI, xAI, zAI, AWS Bedrock, Anthropic, and Google
* Plug into MCP servers and give the assistant access to real systems like GitHub and Forgejo
* Add your own tools and shape the assistant around your workflow instead of someone else's
* Cancel long-running requests and tool calls without leaving the app in a weird state
* Run tools concurrently when one step at a time is too slow
* Built on a small Ruby stack that is easy to understand, extend, and run yourself

## Sounds cool, how does it look?

**Sign-in**

![Relay screenshot](./relay3.png)

**Chat**

![Relay screenshot](./relay1.png)

**MCP**

![Relay screenshot](./relay2.png)


## How do I add my own tool?

Before running `relay start` you should add `~/.config/relay/tools/<yourtool>.rb`.
The tool will be automatically made available to the LLM. This is how a tool
might look - it is not very useful because it does not emit command output
but it serves as a simple example that you can modify and change to meet
your requirements:

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

## Wait, what is a tool?

A tool contains a name, a description, and optional parameters. It is attached
to a method, and that method that can be called. The model or LLM decides when
and how to call a tool. A tool can do anything you can imagine, and it can extend
the abilities of the LLM. Suddenly a LLM can search the web, run code, and anything
you can think of. They're a powerful way to extend the capabilities of an LLM.

An MCP server can also expose pre-packaged tools, and those can be especially
powerful for talking to GitHub or your own Forgejo instance.

## What are the default tools?

The `relay-knowledge` tool returns documentation for both Relay
and [llm.rb](https://github.com/llmrb/llm.rb) - ask about either
of those, and you will be able to have an informed conversation
about both. Good for learning how to use llm.rb, and write your
own tools.

There is also a set of tools that manage a playlist of songs that
can be played inline in the chat, and you can also add your own
songs or remove existing ones through the same tools. The only
requirement is that it is a YouTube URL.

## What provider is the best value?

DeepSeek. I highly recommend it. The context window is 1M. I have been using it
all the time - especially for Relay development, and despite my heavy usage, it
cost only 80 cents overall. It's almost free. I used it **a lot**. I'd estimate
that a 1M context window costs 14 cents or so.

## What about Ollama and friends?

[llm.rb](https://github.com/llmrb/llm.rb#readme) provides support ollama, llama.cpp,
and any OpenAI-compatible endpoint. But Relay does not surface it as a feature. I haven't
had the time or resources to setup either ollama or llamacpp locally.

## Sources

* [GitHub.com](https://github.com/llmrb/relay)
* [GitLab.com](https://gitlab.com/llmrb/relay)
* [Codeberg.org](https://codeberg.org/llmrb/relay)

## License

[BSD Zero Clause](https://choosealicense.com/licenses/0bsd/)
<br>
See [LICENSE](./LICENSE)

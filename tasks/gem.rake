# frozen_string_literal: true

namespace :gem do
  desc "Build Relay assets and package the gem"
  task build: "assets:build" do
    spec = Gem::Specification.load(File.join(Relay.root, "relay.app.gemspec"))
    built = "#{spec.name}-#{spec.version}.gem"
    target = File.join(Relay.root, "pkg", built)
    sh "gem build relay.app.gemspec"
    mkdir_p File.dirname(target)
    mv File.join(Relay.root, built), target, force: true
    puts target
  end

  desc "Build and push the Relay gem"
  task release: :build do
    spec = Gem::Specification.load(File.join(Relay.root, "relay.app.gemspec"))
    sh "gem push #{File.join(Relay.root, "pkg", "#{spec.name}-#{spec.version}.gem")}"
    sh "git tag v#{spec.version}"
  end
end

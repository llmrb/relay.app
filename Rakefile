# frozen_string_literal: true

dir = File.join(__dir__, "app", "frontend")

desc "Build the frontend"
task build: %i[npm:build]

namespace :dev do
  desc "Serve the backend without rebuilding frontend assets"
  task :backend do
    sh "env $(cat .env) " \
       "bundle exec falcon serve --bind http://0.0.0.0:9292"
  end

  desc "Run webpack-dev-server for the frontend"
  task frontend: %i[npm:i] do
    Dir.chdir(dir) do
      sh "npm run dev"
    end
  end
end

namespace :npm do
  desc "Build the frontend"
  task build: %i[npm:i] do
    Dir.chdir(dir) do
      sh "npx webpack build"
    end
  end

  desc "Run 'npm install'"
  task :i do
    Dir.chdir(dir) do
      sh "npm i"
    end
  end
end

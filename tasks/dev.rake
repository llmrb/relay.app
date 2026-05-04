# frozen_string_literal: true

namespace :dev do
  desc "Start the dev environment"
  task :start do
    monitor = Relay::TaskMonitor.new(
      tasks: %w[assets:build assets:watch dev:server]
    )
    monitor.prefork { Relay::DB.disconnect }
    monitor.monitor
  end

  desc "Serve the server"
  task :server do
    sh "env RACK_MULTIPART_BUFFERED_UPLOAD_BYTESIZE_LIMIT=67108864 $(cat #{Relay.env_path}) " \
       "bundle exec falcon serve --bind http://0.0.0.0:9292"
  end
end

# frozen_string_literal: true

require_relative "app/init"

Sequel.extension :migration

def migration_version
  migrator = Sequel::TimestampMigrator.new(Relay::DB, File.join(__dir__, "db", "migrate"))
  migrator.applied_migrations.max.to_s.split("_", 2).first.to_i
end

desc "Build the app"
task build: %i[assets:build]

namespace :db do
  desc "Create a new migration"
  task :new_migration, [:name] do |_task, args|
    abort "usage: rake db:new_migration[name]" if args[:name].to_s.strip.empty?

    timestamp = Time.now.utc.strftime("%Y%m%d%H%M%S")
    path = File.join(__dir__, "db", "migrate", "#{timestamp}_#{args[:name]}.rb")

    File.write(path, <<~RUBY)
      Sequel.migration do
        change do
        end
      end
    RUBY

    puts path
  end

  desc "Run database migrations"
  task :migrate do
    Sequel::Migrator.run(Relay::DB, File.join(__dir__, "db", "migrate"))
  end

  desc "Rollback the latest migration"
  task :rollback do
    path = File.join(__dir__, "db", "migrate")
    version = migration_version

    abort "no migrations applied" if version.to_i.zero?

    Sequel::Migrator.run(Relay::DB, path, target: version - 1)
  end

  desc "Print the current migration version"
  task :version do
    puts migration_version
  end
end

namespace :dev do
  desc "Start the dev environment"
  task :start do
    ch = xchan(:marshal)
    tasks = %w[dev:server dev:sidekiq dev:assets]
    pids = tasks.map do |task|
      fork do
        Rake::Task[task].invoke
      rescue => ex
        ch.send("error")
      end
    end
    pids.each { Process.detach(_1) }
    trap(:SIGINT) { pids.each { Process.kill('SIGHUP', _1) } }
    while ch.empty?
      sleep(1)
    end
  end

  desc "Serve the server"
  task :server do
    sh "env $(cat .env) " \
       "bundle exec falcon serve --bind http://0.0.0.0:9292"
  end

  desc "Run Sidekiq"
  task :sidekiq do
    sh "env $(cat .env) " \
       "bundle exec sidekiq -C app/config/sidekiq.yml -r ./app/init.rb"
  end

  desc "Watch frontend assets"
  task :assets do
    sh "npm --prefix app/assets run assets:watch"
  end
end

namespace :assets do
  desc "Build frontend assets"
  task :build do
    sh "npm --prefix app/assets run assets:build"
  end
end

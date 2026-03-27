Sequel.extension :migration

namespace :db do
  version = proc {
    migrator = Sequel::TimestampMigrator.new(Relay::DB, Relay.migrations_dir)
    migrator.applied_migrations.max.to_s.split("_", 2).first.to_i
  }

  desc "Prepare the database for a fresh setup"
  task :setup do
    FileUtils.mkdir_p File.dirname(Relay::DB.opts[:database])
    Rake::Task["db:migrate"].invoke
  end

  desc "Drop the configured database"
  task :drop do
    abort "db:drop only supports sqlite" unless Relay::DB.database_type == :sqlite
    Relay::DB.disconnect
    FileUtils.rm_f Relay::DB.opts[:database]
  end

  desc "Run database migrations"
  task :migrate do
    Sequel::Migrator.run(Relay::DB, Relay.migrations_dir)
  end

  desc "Rollback the latest migration"
  task :rollback do
    current = version.call
    abort "no migrations applied" if current.zero?
    Sequel::Migrator.run(Relay::DB, Relay.migrations_dir, target: current - 1)
  end

  desc "Seed the database with initial data"
  task :seed => [:migrate] do
    load File.join(Relay.root, "db/seeds.rb")
  end

  desc "Print the current migration version"
  task :version do
    puts version.call
  end

  namespace :migration do
    desc "Create a new migration"
    task :new, [:name] do |_task, args|
      abort "usage: rake db:migrate:new[name]" if args[:name].to_s.empty?
      timestamp = Time.now.utc.strftime("%Y%m%d%H%M%S")
      path = File.join(Relay.migrations_dir, "#{timestamp}_#{args[:name]}.rb")
      erb = ERB.new File.read("templates/migration.rb.erb")
      File.write(path, erb.result(binding))
      puts path
    end
  end
end

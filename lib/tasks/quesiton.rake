task :environment

namespace :question do
  desc "set default required as true"
  task :migrate_required_field => :environment do
    QuestionMigration.migrate_required_field
  end

  desc "set default required as false"
  task :reverse_migrate_required_field => :environment do
    QuestionMigration.reverse_migrate_required_field
  end

end

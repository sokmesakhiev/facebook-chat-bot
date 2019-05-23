task :environment

namespace :question do
  desc "Migrate the existing question required attribute to true"
  task :migrate_required_field => :environment do
    QuestionMigration.migrate_required_field
  end

  desc "Revert migration for the existing question required attribute to false"
  task :reverse_migrate_required_field => :environment do
    QuestionMigration.reverse_migrate_required_field
  end

end

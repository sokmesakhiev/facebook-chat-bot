class MigrateRequiredFieldInQuestions < ActiveRecord::Migration
  def up
    Rake::Task['question:migrate_required_field'].invoke
  end

  def down
    Rake::Task['question:reverse_migrate_required_field'].invoke
  end
end

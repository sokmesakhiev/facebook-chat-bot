class QuestionMigration
  def self.migrate_required_field
    Question.transaction do
      Question.find_each(batch_size: 100) do |question|
        question.required = true
        question.save
      end
    end
  end

  def self.reverse_migrate_required_field
    Question.transaction do
      Question.find_each(batch_size: 100) do |question|
        question.required = false
        question.save
      end
    end
  end

end

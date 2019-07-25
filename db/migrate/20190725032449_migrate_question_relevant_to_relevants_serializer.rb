class MigrateQuestionRelevantToRelevantsSerializer < ActiveRecord::Migration
  def up
    log("Migrating question relevant") do
      Question.all.each do |question|
        if question.relevant_id
          begin
            relevant_question = Question.find question.relevant_id
            condition = Condition.new field: relevant_question.name, operator: question.operator, value: question.relevant_value
            expression = Expressions::OrExpression.new [condition]
            question.relevants = expression.to_yaml
            question.save
            print "."
          rescue
            print "Can't find question with ID: #{question.relevant_id}"
          end
        end
      end
    end
  end

  def down
    log("Reverse migrating question relevant") do
      Question.all.each do |question|
        if question.has_relevants?
          expression = YAML.load question.relevants
          expression.conditions.each do |condition|
            relevant_question = Question.find_by bot_id: question.bot_id, name: condition.field
            if relevant_question
              question.relevant_id = relevant_question.id
              question.operator = condition.operator
              question.relevant_value = condition.value
              question.save
              print "."
            end
          end
        end
      end
    end
  end

  def log(message = "Starting task")
    started_at = Time.now

    print "#{message} is doing\n"
    yield if block_given?
    print "\n#{message} is done in #{Time.now - started_at} seconds.\n"
  end
end

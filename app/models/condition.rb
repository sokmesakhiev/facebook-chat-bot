class Condition
  attr_accessor :field, :operator, :value

  def initialize options = {}
    @field = options[:field] || nil
    @operator = options[:operator] || nil
    @value = options[:value] || nil
  end

  def matched? respondent
    relevant_question = Question.find_by(bot_id: respondent.bot.id, name: field)
    user_response = Survey.last_response respondent, relevant_question

    if !user_response.nil?
      return relevant_question.matched? user_response, self
    end

    false
  end

end

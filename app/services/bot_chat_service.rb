# frozen_string_literal: true

class BotChatService
  attr_accessor :bot, :current

  def initialize(bot)
    @bot = bot
    @total = bot.surveys.length
    @current = 0
  end

  def first
    @current = 0
    current_question
  end

  def next(reponse={})
    @current += 1 if current < @total - 1
    return current_question if current_survey.relevant.blank?

    # current_survey.relevant

    # current_question
  end

  def previous
    @current -= 1 if current > 0
    current_question
  end

  def last
    @current = @total - 1
    current_question
  end

  private

  def current_survey
    bot.surveys[current]
  end

  def current_question
    survey = current_survey
    { survey: survey, choices: survey.choices }
  end
end

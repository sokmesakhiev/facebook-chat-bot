# frozen_string_literal: true

class BotChatService
  attr_accessor :bot, :current

  def initialize(bot)
    @bot = bot
    @current = 0
  end

  def start
    @current = 0
    current_question
  end

  def next
    @current++
    current_question
  end

  def previous
    @current--
    current_question
  end

  private

  def current_question
    survey = bot.surveys[current]
    return { survey: nil, choices: nil } if survey.nil?

    { survey: survey, choices: survey.choices }
  end
end

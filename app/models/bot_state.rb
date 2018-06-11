# frozen_string_literal: true

class BotState
  attr_accessor :bot, :current

  def initialize(bot)
    @bot = bot
    @total = bot.questions.length
    @current = -1
  end

  def first
    @current = 0

    current_question
  end

  def next(question)
    @current = find_current_index(question) + 1

    current_question
  end

  def previous
    @current -= 1 if current > 0
    current_question
  end

  def last
    @current = @total - 1
    current_question
  end

  def find_current_index(question)
    return -1 if question.nil?
    
    bot.questions.index { |q| q.id == question.id }
  end

  def first? question
    !bot.has_question? && bot.questions.first.id == question.id
  end

  def last?(question)
    !bot.has_question? && bot.questions.last.id == question.id
  end

  private

  def current_question
    return nil if current < 0 || current >= @total

    bot.questions[current]
  end
end

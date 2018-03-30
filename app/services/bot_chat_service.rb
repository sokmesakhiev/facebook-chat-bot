# frozen_string_literal: true

class BotChatService
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

  def next(option = {})
    if option[:current].present?
      @current = option[:current] + 1
    elsif current < @total - 1
      @current += 1
    end

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

  def find_current_index(id)
    bot.questions.index { |q| q.id == id }
  end

  def last?(question_id)
    !bot.questions.empty? && bot.questions.last.id == question_id
  end

  private

  def current_question
    bot.questions[current]
  end
end
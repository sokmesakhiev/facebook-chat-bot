require 'rails_helper'

RSpec.describe BotChatService do
  # context 'no skip logic surveys' do
  #   let!(:bot) { create(:bot, :with_simple_surveys_and_choices) }
  #   let!(:bot_service) { BotChatService.new(bot) }

  #   it '#first' do
  #   end

  #   it '#next' do
  #   end

  #   it '#previous' do
  #   end

  #   it '#last' do
  #   end
  # end

  context 'has skip logic surveys' do
    let!(:bot) { create(:bot, :with_skip_logic_surveys_and_choices) }
    let!(:bot_service) { BotChatService.new(bot) }

    # it '#first' do
    # end

    describe '#next' do
      it 'returns next question as favorite_topping' do
        current_question = bot_service.next({likes_pizza: 'yes'})
        expect(current_question[:survey][:name]).to eq 'favorite_topping'
      end

      # it 'returns next question as favorite_cheese' do
      #   current_question = bot_service.next({favorite_topping: 'cheese'})
      #   expect(current_question.survey.name).to eq 'favorite_cheese'
      # end

      # it 'returns nil after likes_pizza' do
      #   current_question = bot_service.next({likes_pizza: 'no'})
      #   expect(current_question.survey.name).to eq nil
      # end

      # it 'returns nil after favorite_topping' do
      #   current_question = bot_service.next({favorite_topping: 'pepperoni'})
      #   expect(current_question.survey.name).to eq nil
      # end
    end

    # it '#previous' do
    # end

    # it '#last' do
    # end
  end
end

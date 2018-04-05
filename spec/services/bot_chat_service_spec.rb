require 'rails_helper'

RSpec.describe BotChatService do
  let(:bot) { create(:bot, :with_simple_surveys_and_choices, facebook_page_id: '1512165178836125') }
  let(:bot_service) { BotChatService.new(bot) }

  it '#first' do
    expect(bot_service.first.name).to eq('username')
  end

  context '#next' do
    it 'returns question name age' do
      bot_service.next

      expect(bot_service.next.name).to eq('age')
    end

    it 'returns question name sex' do
      bot_service.next
      bot_service.next

      expect(bot_service.next.name).to eq('sex')
    end

    it 'returns question name dob' do
      bot_service.next
      bot_service.next
      bot_service.next

      expect(bot_service.next.name).to eq('dob')
    end

    it 'returns question name favorite_foods' do
      bot_service.next
      bot_service.next
      bot_service.next
      bot_service.next

      expect(bot_service.next.name).to eq('favorite_foods')
    end

    it 'returns nil' do
      bot_service.next
      bot_service.next
      bot_service.next
      bot_service.next
      bot_service.next

      expect(bot_service.next).to eq(nil)
    end

    it 'returns next question when have params' do
      expect(bot_service.next(current: 1).name).to eq('sex')
    end
  end

  context '#previous' do
    it 'returns nil' do
      expect(bot_service.previous).to eq(nil)
    end

    it 'returns nil' do
      bot_service.previous

      expect(bot_service.previous).to eq(nil)
    end

    it 'returns previous' do
      bot_service.next(current: 1)
      expect(bot_service.previous.name).to eq('age')
    end
  end

  it '#last' do
    expect(bot_service.last.name).to eq('favorite_foods')
  end

  it '#find_current_index' do
    expect(bot_service.find_current_index(bot.questions.last.id)).to eq(4)
  end

  context '#last?' do
    it 'returns true' do
      expect(bot_service.last?(bot.questions.last.id)).to eq(true)
    end

    it 'returns false' do
      expect(bot_service.last?(bot.questions.first.id)).to eq(false)
    end
  end
end

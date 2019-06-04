require 'rails_helper'

RSpec.describe FileUtil do

  describe '.image_url' do
    let(:bot) { create(:bot) }
    it{
      expect(FileUtil.image_url(bot, 'image.png')).to eq "#{ENV['HOST']}/upload/survey/bot_#{bot.id}/image.png"
    }
  end
end

require 'rails_helper'

describe BotPolicy do
  subject { described_class }

  permissions :create?, :new? do
    it 'denies access if user is an admin' do
      expect(subject).to permit(User.new(role: 'admin'), Bot.new(name: 'Woona'))
    end

    it 'grants access if user is not an admin' do
      expect(subject).to permit(User.new(role: 'user'), Bot.new(name: 'Woona'))
    end
  end

  permissions :update?, :edit? do
    it 'grants access if user is an admin' do
      expect(subject).to permit(User.new(role: 'admin'), Bot.new(name: 'Woona'))
    end

    it 'grants access if user is not an admin' do
      expect(subject).to permit(User.new(role: 'user'), Bot.new(name: 'Woona'))
    end
  end

  describe '.policy_scope' do
    let(:admin)  { create(:user, :admin) }
    let(:user1)  { create(:user, :user) }
    let(:user2)  { create(:user, :user) }
    let(:bot1)   { user1.bots.create(name: 'woona') }
    let(:bot2)   { user2.bots.create(name: 'woom') }

    it "returns all bots if user is an admin" do
      expect(Pundit.policy_scope(admin, Bot)).to eq [bot1, bot2]
    end

    it "returns bot1 if user is user1" do
      expect(Pundit.policy_scope(user1, Bot)).to eq [bot1]
    end

    it "returns bot2 if user is user2" do
      expect(Pundit.policy_scope(user2, Bot)).to eq [bot2]
    end
  end
end

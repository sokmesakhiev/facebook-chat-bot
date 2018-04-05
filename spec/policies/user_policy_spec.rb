require 'rails_helper'

describe UserPolicy do
  subject { described_class }

  permissions :index?, :show?, :create?, :new?, :update?, :edit?, :destroy? do
    it 'denies access if user is not an admin' do
      expect(subject).not_to permit(User.new(role: 'user'))
    end

    it 'grants access if user is an admin' do
      expect(subject).to permit(User.new(role: 'admin'))
    end
  end
end

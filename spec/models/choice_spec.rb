require 'rails_helper'

RSpec.describe Choice do
  it { is_expected.to belong_to(:question) }
end

# == Schema Information
#
# Table name: choices
#
#  id          :integer          not null, primary key
#  question_id :integer
#  name        :string(255)
#  label       :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'rails_helper'

RSpec.describe Choice do
  it { is_expected.to belong_to(:question) }
end

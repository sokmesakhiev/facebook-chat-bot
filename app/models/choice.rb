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

class Choice < ApplicationRecord
  belongs_to :question

  def value
    name.numeric? ? name.to_i : name
  end
end

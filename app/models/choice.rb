# == Schema Information
#
# Table name: choices
#
#  id          :integer          not null, primary key
#  question_id :integer
#  name        :string(255)
#  label       :string(255)
#

class Choice < ApplicationRecord
  belongs_to :question
end

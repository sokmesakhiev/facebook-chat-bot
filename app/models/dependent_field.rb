# == Schema Information
#
# Table name: dependent_fields
#
#  id          :integer          not null, primary key
#  question_id :integer
#  operator    :string(255)
#  value       :string(255)
#

class DependentField < ApplicationRecord
  belongs_to :question
end

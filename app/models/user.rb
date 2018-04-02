# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  provider               :string(255)
#  uid                    :string(255)
#  name                   :string(255)
#  oauth_token            :string(255)
#  oauth_expires_at       :datetime
#  created_at             :datetime
#  updated_at             :datetime
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  role                   :string(255)
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:facebook]

  ROLES = %w[user admin].freeze

  has_many :bots, dependent: :destroy

  before_validation(on: :create) do
    pwd = SecureRandom.hex(8)
    self.password ||= pwd
    self.password_confirmation ||= pwd
  end

  validates :role, inclusion: { in: ROLES }

  def admin?
    role == 'admin'
  end

  def self.from_omniauth(params)
    user = User.find_by(email: params['info']['email'])

    return nil if user.nil?

    user.update(
      oauth_token: params['credentials']['token'],
      name: params['info']['name'],
      uid: params['uid']
    )

    user
  end
end

class User < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper

  # Include default devise modules. Others available are:
  # :confirmable, :database_authenticatable, :lockable, :recoverable, :registerable
  # :timeoutable, and :validatable
  devise :rememberable, :trackable, :omniauthable, omniauth_providers: [:google_oauth2]

  has_one :token
  has_many :gigs

  def access_token
    token.fresh_token
  end

  def find_or_create_token(auth)
    return access_token if token
    create_token(
      access_token: auth.credentials.token,
      refresh_token: auth.credentials.refresh_token,
      expires_at: Time.at(auth.credentials.expires_at).to_datetime
    )
  end

  def formatted_monthly_goal
    number_to_currency(self.monthly_goal)
  end

  def has_completed_setup?
    self.monthly_goal.present?
  end

  def self.find_for_google_oauth2(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name
      user.calendar_id = auth.info.email
    end
  end

end

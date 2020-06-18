class UpsertUserForFranceConnectService < BaseService
  attr_reader :user, :new_user
  alias new_user? new_user

  def initialize(omniauth_info)
    @email = omniauth_info.email
    @first_name = omniauth_info.given_name
    @last_name = omniauth_info.family_name
    @birth_date = omniauth_info.birthdate
    @france_connect_openid_sub = omniauth_info.sub
  end

  def perform
    @user = User.find_by(email: @email)
    if @user.present?
      update_existing_user
    else
      create_new_user
    end
    self
  end

  private

  def update_existing_user
    @new_user = false
    [:birth_date, :france_connect_openid_sub].each { update_field(_1) }
    @user.save!
  end

  def create_new_user
    @new_user = true
    @user = User
      .new(
        email: @email,
        first_name: @first_name,
        last_name: @last_name,
        birth_date: @birth_date,
        france_connect_openid_sub: @france_connect_openid_sub,
        created_through: "france_connect_sign_up"
      )
    @user.skip_confirmation!
    @user.save!
    @user
  end

  def update_field(name)
    return if @user.send(name).present? # do not override existing fields

    value_from_omniauth = instance_variable_get("@#{name}")
    return if value_from_omniauth.blank? # do not fill with missing values

    @user.send("#{name}=", value_from_omniauth)
  end
end

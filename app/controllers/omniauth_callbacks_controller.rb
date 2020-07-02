class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def france_connect
    upsert_service = UpsertUserForFranceConnectService
      .perform_with(request.env["omniauth.auth"]["info"])

    flash[:success] = upsert_service.new_user? ? "Votre compte a été créé" : "Vous êtes connecté·e"
    bypass_sign_in upsert_service.user, scope: :user
    redirect_to after_sign_in_path_for(upsert_service.user)
  end

  def github
    email = request.env["omniauth.auth"]["info"]["email"]
    super_admin = SuperAdmin.find_by(email: email)

    if super_admin.present?
      bypass_sign_in super_admin, scope: :super_admin
      redirect_to admin_agents_path
    else
      flash[:alert] = "Compte GitHub non autorisé"
      Rails.logger.error("OmniAuth failed for #{email}")
      redirect_to root_path
    end
  end
end

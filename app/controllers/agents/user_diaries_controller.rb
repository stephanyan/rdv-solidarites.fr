class Agents::UserDiariesController < AgentAuthController
  def create
    user = User.find(params[:user_id])
    authorize(user)
    UserDiary.create!(organisation: current_organisation, user: user, agent: current_agent, text: params[:user_diary][:text])
    redirect_back(fallback_location: organisation_user_path(current_organisation, user))
  end
end

class Agents::UserDiariesController < AgentAuthController
  def create
    user = User.find(params[:user_id])
    authorize(user)
    UserDiary.create!(organisation: current_organisation, user: user, agent: current_agent, text: params[:user_diary][:text])
    if request.headers["HTTP_REFERER"]
      redirect_to(request.headers["HTTP_REFERER"] += '#notes')
    else
      redirect_to organisation_user_path(current_organisation, user, anchor: "notes")
    end
  end
end

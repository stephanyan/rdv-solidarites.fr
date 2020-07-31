class Agents::NotesController < AgentAuthController
  def index
    rdv = Rdv.find(params[:rdv_id])
    @user = rdv.users.first
    @notes = rdv.notes
    @back_path = request.headers["REFERER"]
  end
end

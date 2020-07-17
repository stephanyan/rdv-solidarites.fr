describe Agents::UserDiariesController, type: :controller do
  render_views

  describe "#create" do
    it "works" do
      agent = create(:agent)
      organisation = agent.organisations.first
      user = create(:user, organisations: [organisation])
      sign_in agent
      expect  do
        post :create, params: { organisation_id: organisation.id, user_id: user.id, "user_diary" => { "text" => "un truc nouveau à ajouter" } }
      end.to change(UserDiary, :count).by(1)
      expect(response).to redirect_to(organisation_user_path(organisation, user))
    end
  end
end

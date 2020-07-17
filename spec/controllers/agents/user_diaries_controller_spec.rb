describe Agents::UserDiariesController, type: :controller do
  render_views

  describe "#create" do
    it "from user page, create a diary and redirect to user page" do
      agent = create(:agent)
      organisation = agent.organisations.first
      user = create(:user, organisations: [organisation])
      sign_in agent
      expect  do
        post :create, params: { organisation_id: organisation.id, user_id: user.id, "user_diary" => { "text" => "un truc nouveau à ajouter" } }
      end.to change(UserDiary, :count).by(1)
      expect(response).to redirect_to(organisation_user_path(organisation, user))
    end

    it "from rdv page, create a diary for each users of rdv, and redirect to rdv page" do
      organisation = create(:organisation)
      user = create(:user, organisations: [organisation])
      enfant = create(:user, :relative, responsible: user)
      rdv = create(:rdv, :future, users: [user, enfant], organisation: organisation)
      agent = rdv.agents.first
      sign_in agent

      request.headers["Referer"] = organisation_rdv_path(organisation, rdv)
      expect do
        post :create, params: { organisation_id: organisation.id, user_id: user.id, "user_diary" => { "user_ids" => enfant.id.to_s, "text" => "un truc nouveau à ajouter" } }
      end.to change(UserDiary, :count).by(1)
      expect(response).to redirect_to(organisation_rdv_path(organisation, rdv))
    end
  end
end

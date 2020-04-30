describe CreneauxBuilderService, type: :service do
  let!(:motif) { create(:motif, name: "Vaccination", default_duration_in_min: 30, online: online) }
  let(:online) { true }
  let!(:lieu) { create(:lieu) }
  let(:today) { Date.new(2019, 9, 19) }
  let(:six_days_later) { today + 6.days }
  let!(:plage_ouverture) { create(:plage_ouverture, motifs: [motif], lieu: lieu, first_day: today, start_time: Tod::TimeOfDay.new(9), end_time: Tod::TimeOfDay.new(11)) }
  let(:agent) { plage_ouverture.agent }
  let(:now) { today.to_time }
  let(:for_agents) { nil }
  let(:agent_ids) { nil }
  let(:motif_name) { motif.name }
  let(:next_7_days_range) { today..six_days_later }

  before { travel_to(now) }
  after { travel_back }

  subject do
    creneaux = CreneauxBuilderService.perform_with(motif_name, lieu, next_7_days_range, for_agents: for_agents, agent_ids: agent_ids)
    creneaux.map { |c| creneau_to_hash(c, for_agents) }
  end

  it "should work" do
    expect(subject.size).to eq(4)

    is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 9, 0), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id)
    is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 9, 30), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id)
    is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 10, 0), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id)
    is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 10, 30), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id)
  end

  context "with motif not bookable online" do
    let(:online) { false }

    it "should return 0 creneaux" do
      expect(subject.size).to eq(0)
    end

    context "when the result is for pros" do
      let(:for_agents) { true }

      it do
        expect(subject.size).to eq(4)

        is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 9, 0), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id, agent_id: agent.id, agent_name: agent.short_name)
        is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 9, 30), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id, agent_id: agent.id, agent_name: agent.short_name)
        is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 10, 0), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id, agent_id: agent.id, agent_name: agent.short_name)
        is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 10, 30), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id, agent_id: agent.id, agent_name: agent.short_name)
      end
    end
  end

  context "with absences" do
    let!(:absence) { create(:absence, agent: agent, first_day: Date.new(2019, 9, 19), start_time: Tod::TimeOfDay.new(9, 45), end_day: Date.new(2019, 9, 19), end_time: Tod::TimeOfDay.new(10, 15)) }

    it do
      expect(subject.size).to eq(2)

      is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 9, 0), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id)
      is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 10, 30), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id)
    end
  end

  context "with recurring absences" do
    let!(:absence) { create(:absence, :weekly, agent: agent, first_day: Date.new(2019, 9, 12), start_time: Tod::TimeOfDay.new(9, 45), end_day: Date.new(2019, 9, 12), end_time: Tod::TimeOfDay.new(10, 15)) }

    it do
      expect(subject.size).to eq(2)

      is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 9, 0), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id)
      is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 10, 30), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id)
    end
  end

  context "with a RDV" do
    let!(:rdv) { create(:rdv, starts_at: Time.zone.local(2019, 9, 19, 9, 30), duration_in_min: 30, agents: [agent]) }

    it do
      expect(subject.size).to eq(3)

      is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 9, 0), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id)
      is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 10, 0), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id)
      is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 10, 30), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id)
    end
  end

  context "with a cancelled RDV" do
    let!(:rdv) { create(:rdv, starts_at: Time.zone.local(2019, 9, 19, 9, 30), duration_in_min: 30, agents: [agent], cancelled_at: Time.zone.local(2019, 9, 20, 9, 30)) }

    it do
      expect(subject.size).to eq(4)

      is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 9, 0), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id)
      is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 9, 30), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id)
      is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 10, 0), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id)
      is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 10, 30), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id)
    end
  end

  context "with a RDV on the last day of the range" do
    let!(:plage_ouverture) { create(:plage_ouverture, motifs: [motif], lieu: lieu, first_day: Date.new(2019, 9, 25), start_time: Tod::TimeOfDay.new(9), end_time: Tod::TimeOfDay.new(11)) }
    let!(:rdv) { create(:rdv, starts_at: Time.zone.local(2019, 9, 25, 10, 0), duration_in_min: 30, agents: [agent]) }

    it do
      expect(subject.size).to eq(3)

      is_expected.to include(starts_at: Time.zone.local(2019, 9, 25, 9, 0), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id)
      is_expected.to include(starts_at: Time.zone.local(2019, 9, 25, 9, 30), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id)
      is_expected.to include(starts_at: Time.zone.local(2019, 9, 25, 10, 30), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id)
    end
  end

  context "when today is jour ferie" do
    let(:today) { Date.new(2020, 1, 1) }

    it do
      expect(subject.size).to eq(0)
    end
  end

  context "when there are two agents" do
    let(:agent2) { create(:agent) }
    let!(:plage_ouverture2) { create(:plage_ouverture, agent: agent2, motifs: [motif], lieu: lieu, first_day: today, start_time: Tod::TimeOfDay.new(10), end_time: Tod::TimeOfDay.new(12)) }

    it do
      expect(subject.size).to eq(6)

      is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 9, 0), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id)
      is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 9, 30), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id)
      is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 10, 0), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id)
      is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 10, 30), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id)
      is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 11, 0), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id)
      is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 11, 30), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id)
    end

    context "when the result is for agents" do
      let(:for_agents) { true }

      it do
        expect(subject.size).to eq(8)

        is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 9, 0), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id, agent_id: agent.id, agent_name: agent.short_name)
        is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 9, 30), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id, agent_id: agent.id, agent_name: agent.short_name)
        is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 10, 0), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id, agent_id: agent2.id, agent_name: agent2.short_name)
        is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 10, 0), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id, agent_id: agent.id, agent_name: agent.short_name)
        is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 10, 30), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id, agent_id: agent2.id, agent_name: agent2.short_name)
        is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 10, 30), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id, agent_id: agent.id, agent_name: agent.short_name)
        is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 11, 0), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id, agent_id: agent2.id, agent_name: agent2.short_name)
        is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 11, 30), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id, agent_id: agent2.id, agent_name: agent2.short_name)
      end

      context "when the result is filtered for agent2" do
        let(:agent_ids) { [agent2.id] }

        it do
          expect(subject.size).to eq(4)

          is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 10, 0), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id, agent_id: agent2.id, agent_name: agent2.short_name)
          is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 10, 30), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id, agent_id: agent2.id, agent_name: agent2.short_name)
          is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 11, 0), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id, agent_id: agent2.id, agent_name: agent2.short_name)
          is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 11, 30), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id, agent_id: agent2.id, agent_name: agent2.short_name)
        end
      end
    end
  end

  context "when motif has min_booking_delay" do
    let!(:motif) { create(:motif, name: "Vaccination", default_duration_in_min: 30, min_booking_delay: 30.minutes, online: true) }
    let(:now) { Time.zone.local(2019, 9, 19, 9, 15) }

    it do
      expect(subject.size).to eq(2)

      is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 10, 0), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id)
      is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 10, 30), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id)
    end
  end

  context "when motif has max_booking_delay" do
    let!(:motif) { create(:motif, name: "Vaccination", default_duration_in_min: 30, max_booking_delay: 45.minutes, online: true) }
    let(:now) { Time.zone.local(2019, 9, 19, 9, 15) }

    it do
      expect(subject.size).to eq(1)

      is_expected.to include(starts_at: Time.zone.local(2019, 9, 19, 10, 0), duration_in_min: 30, lieu_id: lieu.id, motif_id: motif.id)
    end
  end

  def expect_creneau_to_eq(creneau, attr = {})
    expect(creneau.starts_at).to eq(attr[:starts_at])
    expect(creneau.duration_in_min).to eq(attr[:duration_in_min])
    expect(creneau.lieu.id).to eq(attr[:lieu_id])
    expect(creneau.motif.id).to eq(attr[:motif].id)
    expect(creneau.agent_id).to eq(attr[:agent_id]) if attr[:agent_id].present?
    expect(creneau.agent_name).to eq(attr[:agent_name]) if attr[:agent_name].present?
  end

  def creneau_to_hash(creneau, with_agent = false)
    {
      starts_at: creneau.starts_at,
      duration_in_min: creneau.duration_in_min,
      lieu_id: creneau.lieu.id,
      motif_id: creneau.motif.id,
      agent_id: (creneau.agent_id if with_agent),
      agent_name: (creneau.agent_name if with_agent),
    }.compact
  end
end
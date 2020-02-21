describe Rdv, type: :model do
  include ActiveJob::TestHelper

  after(:each) do
    clear_enqueued_jobs
  end

  describe '#send_web_hook' do
    let(:rdv) { create(:rdv, starts_at: "2020-02-17T10:20") }

    RSpec::Matchers.define :date_in_iso_format do
      match { |actual| (actual.to_json.match?(/"starts_at"\:"2020-02-17T10:20:00.000\+01\:00"/)) }
    end

    describe 'default publication' do
      it 'publishes the default status' do
        expect(WebHookJob).to receive(:perform_later).with(hash_including(status: 'unknown'))
        rdv.reload
      end

      it 'publishes will convert to valid ISO dates' do
        expect(WebHookJob).to receive(:perform_later).with(date_in_iso_format)
        rdv.reload
      end
    end

    describe 'publication on update' do
      before { rdv.reload }

      it 'publishes the new status' do
        expect(WebHookJob).to receive(:perform_later).with(hash_including(status: 'excused'))
        rdv.status = :excused
        rdv.save
      end

      it 'publishes the deleted status' do
        expect(WebHookJob).to receive(:perform_later).with(hash_including(status: 'deleted'))

        rdv.destroy
      end
    end
  end
end

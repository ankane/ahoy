describe Ahoy::Tracker do
  let(:request_data) {OpenStruct.new(user_agent: 'user_agent', headers: {}, cookies: {}, params: {})}
  describe 'tracking a visit' do
    it 'must increase the amount of Visits' do
      allow_any_instance_of(Ahoy::Tracker).to receive(:delete_cookie).and_return(true)
      expect{Ahoy::Tracker.new({request: request_data}).track_visit}.to change{Ahoy::Visit.count}.by 1
    end
  end
end

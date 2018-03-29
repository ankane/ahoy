describe Ahoy::Tracker do
  describe 'tracking a visit' do
    it 'must increase the amount of Visits' do
      allow_any_instance_of(Ahoy::Tracker).to receive(:delete_cookie).and_return(true)
      tracker = Ahoy::Tracker.new({request: create(:request_data)})
      expect{tracker.track_visit}.to change{Ahoy::Visit.count}.by 1
    end
  end
end

Warden::Manager.after_set_user except: :fetch do |user, auth, opts|
  request = ActionDispatch::Request.new(auth.env)
  ahoy = Ahoy::Tracker.new(request: request)
  visit = ahoy.current_visit
  if visit and !visit.user
    visit.user = user
    visit.save!
  end
  ahoy.track "$authenticate", {}, user: user
end

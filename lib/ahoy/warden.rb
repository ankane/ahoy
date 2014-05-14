Warden::Manager.after_set_user except: :fetch do |user, auth, opts|
  request = ActionDispatch::Request.new(auth.env)
  visit_token = request.cookies["ahoy_visit"] || request.headers["Ahoy-Visit"]
  visit = nil
  if visit_token
    visit = Ahoy.visit_model.where(visit_token: visit_token).first
    if visit and !visit.user
      visit.user = user
      visit.save!
    end
  end
  ahoy = Ahoy::Tracker.new
  ahoy.track "$authenticate", {}, user: user, visit: visit
end

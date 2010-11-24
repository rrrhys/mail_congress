class SessionsController < Devise::SessionsController

  def create
    resource = warden.authenticate!(:scope => resource_name, :recall => 'home#index')
    set_flash_message :notice, :signed_in
    sign_in_and_redirect(resource_name, resource)
  end

  private

  def after_sign_in_path_for(resource)
    dashboard_path
  end

end

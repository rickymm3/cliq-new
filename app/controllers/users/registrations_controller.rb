# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]



  # If you need to customize other methods, you can do so here.
  # For instance, you might want to customize the paths after certain actions:

  def after_sign_up_path_for(resource)
    # Define the path where users are redirected after signing up
    # For example:
    root_path
  end

  def new
    build_resource({})
    resource.build_profile # This ensures a Profile object is created for the user
    respond_with resource
  end
  
  def create
    build_resource(sign_up_params)
  
    resource.build_profile unless resource.profile # Ensure profile is built
  
    if resource.save
      sign_up(resource_name, resource)
      respond_with resource, location: after_sign_up_path_for(resource)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private 
  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, profile_attributes: [:username])
  end

  def account_update_params
    params.require(:user).permit(:email, :password, :password_confirmation, :current_password, profile_attributes: [:username])
  end
  # If you want to add additional logic before or after certain actions,
  # you can override methods like create, update, etc., but remember to call super:

  # def create
  #   super do |user|
  #     # Additional logic after user creation
  #     # For example, sending a welcome email:
  #     # UserMailer.with(user: user).welcome_email.deliver_later if user.persisted?
  #   end
  # end

  # def update
  #   super do |user|
  #     # Additional logic after user update
  #     # For example, updating session if needed:
  #     # sign_in(user, bypass: true) if user.persisted?
  #   end
  # end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end

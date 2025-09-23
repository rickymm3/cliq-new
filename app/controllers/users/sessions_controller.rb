class Users::SessionsController < Devise::SessionsController
  # Devise 4.9+ with Turbo: use 303 See Other after POST/DELETE
  def create
    super do |resource|
      target = after_sign_in_path_for(resource)
      respond_to do |format|
        format.html { return redirect_to(target) }
        format.turbo_stream { return redirect_to(target, status: :see_other) }
      end
    end
  end

  def destroy
    super do
      target = after_sign_out_path_for(resource_name)
      respond_to do |format|
        format.html { return redirect_to(target) }
        format.turbo_stream { return redirect_to(target, status: :see_other) }
      end
    end
  end
end

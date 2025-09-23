class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

# POST /subscriptions?cliq_id=123
  def create
    @cliq = Cliq.find(params[:cliq_id])

    # If a parent is already subscribed, do not create a child subscription.
    if (ancestor = current_user.subscribed_ancestor_for(@cliq))
      if turbo_frame_request?
        # Just re-render the button showing inherited state
        render partial: "cliqs/subscribe_button", locals: { cliq: @cliq }
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              view_context.dom_id(@cliq, :subscribe_button),
              partial: "cliqs/subscribe_button",
              locals: { cliq: @cliq }
            )
          end
          format.html { redirect_to cliq_path(@cliq) }
        end
      end
      return
    end

    # Otherwise: create (or find) the direct subscription to this cliq
    @subscription = current_user.subscriptions.find_or_initialize_by(cliq: @cliq)
    if @subscription.persisted? || @subscription.save
      # If this is a parent, collapse any existing child subscriptions
      child_ids = current_user.descendant_ids_for(@cliq)
      if child_ids.any?
        current_user.subscriptions.where(cliq_id: child_ids).delete_all
      end

      if turbo_frame_request?
        render partial: "cliqs/subscribe_button", locals: { cliq: @cliq }
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              view_context.dom_id(@cliq, :subscribe_button),
              partial: "cliqs/subscribe_button",
              locals: { cliq: @cliq }
            )
          end
          format.html { redirect_to cliq_path(@cliq) }
        end
      end
    else
      head :unprocessable_entity
    end
  end

  # PATCH /subscriptions/:id/toggle
  def toggle
    @subscription = current_user.subscriptions.find(params[:id])
    @subscription.update!(enabled: !@subscription.enabled)

    # We need to re-render just the pill/row in the Profile UI
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          view_context.dom_id(@subscription, :pill),
          partial: "profiles/subscription_pill",
          locals: { subscription: @subscription }
        )
      end
      format.html { redirect_to profile_path(current_user.profile) }
    end
  end
  
  # DELETE /subscriptions/:id  OR  /subscriptions?cliq_id=123
  def destroy
    @subscription = current_user.subscriptions.find(params[:id]) rescue find_subscription!
    @cliq = @subscription.cliq
  
    if @subscription.destroy
      if params[:context] == "profile_row"
        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.remove(view_context.dom_id(@subscription)) }
          format.html { redirect_to profile_path(current_user.profile) }
        end
  
      elsif turbo_frame_request?
        # If we’re on a CHILD cliq page showing “Unsubscribe {parent}”,
        # render the CHILD page’s subscribe frame so IDs match.
        render_cliq = params[:target_cliq_id].present? ? Cliq.find(params[:target_cliq_id]) : @cliq
        render partial: "cliqs/subscribe_button", locals: { cliq: render_cliq }
  
      else
        respond_to do |format|
          render_cliq = params[:target_cliq_id].present? ? Cliq.find(params[:target_cliq_id]) : @cliq
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              view_context.dom_id(render_cliq, :subscribe_button),
              partial: "cliqs/subscribe_button",
              locals: { cliq: render_cliq }
            )
          end
          format.html { redirect_to cliq_path(render_cliq) }
        end
      end
    else
      head :unprocessable_entity
    end
  end
  
  # GET /subscriptions/:id/confirm
  def confirm
    @subscription = current_user.subscriptions.find(params[:id])
    # Always return the frame HTML (no turbo_stream here)
    render partial: "subscriptions/confirm_row", locals: { subscription: @subscription }, status: :ok
  end

  # GET /subscriptions/:id/row
  def row
    @subscription = current_user.subscriptions.find(params[:id])
    # Always return the frame HTML
    render partial: "subscriptions/row", locals: { subscription: @subscription }, status: :ok
  end

  private


  def parent_group_for(cliq)
    cliq.ancestors.any? ? cliq.ancestors.first : cliq
  end

  # Supports either /subscriptions/:id or /subscriptions?cliq_id=
  def find_subscription!
    if params[:id].present?
      current_user.subscriptions.find(params[:id])
    else
      cliq = Cliq.find(params[:cliq_id])
      current_user.subscriptions.find_by!(cliq: cliq)
    end
  end
end

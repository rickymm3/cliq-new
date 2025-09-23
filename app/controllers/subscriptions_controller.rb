class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  # POST /subscriptions?cliq_id=123
  def create
    @cliq = Cliq.find(params[:cliq_id])
    @subscription = current_user.subscriptions.find_or_initialize_by(cliq: @cliq)

    if @subscription.persisted? || @subscription.save
      respond_to do |format|
        # Re-render the subscribe button frame on the cliq page
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            dom_id(@cliq, :subscribe_button),
            partial: "cliqs/subscribe_button",
            locals: { cliq: @cliq, subscribed: true }
          )
        end

        format.html { redirect_to cliq_path(@cliq) }
      end
    else
      head :unprocessable_entity
    end
  end

  # DELETE /subscriptions/:id  OR  /subscriptions?cliq_id=123
  def destroy
    @subscription = find_subscription!
    @cliq = @subscription.cliq

    if @subscription.destroy
      respond_to do |format|
        format.turbo_stream do
          # If request came from a profile row, remove the row.
          if params[:context] == "profile_row"
            render turbo_stream: turbo_stream.remove(dom_id(@subscription))
          else
            # Otherwise, we assume cliq page: flip the button back.
            render turbo_stream: turbo_stream.replace(
              dom_id(@cliq, :subscribe_button),
              partial: "cliqs/subscribe_button",
              locals: { cliq: @cliq, subscribed: false }
            )
          end
        end

        format.html { redirect_to cliq_path(@cliq) }
      end
    else
      head :unprocessable_entity
    end
  end

  # GET /subscriptions/:id/confirm  (Turbo-swaps a single profile row into confirm UI)
  def confirm
    @subscription = current_user.subscriptions.find(params[:id])
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          dom_id(@subscription),
          partial: "subscriptions/confirm_row",
          locals: { subscription: @subscription }
        )
      end
      format.html { redirect_to user_path(current_user) }
    end
  end

  # GET /subscriptions/:id/row  (Reverts a profile row from confirm UI)
  def row
    @subscription = current_user.subscriptions.find(params[:id])
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          dom_id(@subscription),
          partial: "subscriptions/row",
          locals: { subscription: @subscription }
        )
      end
      format.html { redirect_to user_path(current_user) }
    end
  end

  private

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

class RepliesController < ApplicationController
  before_action :set_reply, only: %i[ show edit update destroy ]
  before_action :set_post, only: %i[ create ]

  # GET /replies or /replies.json
  def index
    @replies = Reply.all
  end

  # GET /replies/1 or /replies/1.json
  def show
  end

  # GET /replies/new
  def new
    @post = Post.friendly.find(params[:post_id])
    @reply = Reply.new
    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  # GET /replies/1/edit
  def edit
  end

  # POST /replies or /replies.json
  def create
    @reply = @post.replies.build(reply_params)
    @reply.user = current_user
    @reply.post =  # Assuming replies are nested under posts
    if @reply.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @post, notice: 'Reply was successfully created.' }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace('reply_form', partial: 'replies/form', locals: { post: @post, reply: @reply }) }
        format.html { render 'posts/show', status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /replies/1 or /replies/1.json
  def update
    respond_to do |format|
      if @reply.update(reply_params)
        format.html { redirect_to @reply, notice: "Reply was successfully updated." }
        format.json { render :show, status: :ok, location: @reply }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @reply.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /replies/1 or /replies/1.json
  def destroy
    @reply.destroy

    respond_to do |format|
      format.html { redirect_to replies_path, status: :see_other, notice: "Reply was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_post
      @post = Post.friendly.find(params[:reply][:post_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_reply
      @reply = Reply.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def reply_params
      params.require(:reply).permit(:content, :post_id, :user_id)
    end
end

class PostsController < ApplicationController
  # before_action :set_post, only: %i[ show edit update destroy ]

  # GET /posts or /posts.json
  # def index
  #   if params[:cliq_id]
  #     @cliq = Cliq.find(params[:cliq_id])
  #     cliq_ids = @cliq.self_and_descendant_ids
  #     @posts = Post.where(cliq_id: cliq_ids).order(created_at: :desc)
  #   else
  #     @posts = Post.all.order(created_at: :desc) # or whatever default behavior you want
  #   end
  #   # Render or redirect as per your application's needs
  # end

  def index
    # if params[:cliq_id]
    #   @cliq = Cliq.find(params[:cliq_id])
    #   cliq_ids = @cliq.self_and_descendant_ids
    #   @posts = Post.where(cliq_id: cliq_ids).order(created_at: :desc)
    # else
    #   @cliq = Cliq.find_by(parent_cliq_id: nil)
    #   @posts = Post.all.order(created_at: :desc) 
    # end
  
    # # Assuming you're using some form of pagination like Kaminari or Pagy
    # @posts = @posts.page(params[:page]).per(10) # Adjust per_page as needed
  
    # respond_to do |format|
    #   format.html # Renders the index.html.erb
    #   format.turbo_stream do
    #     render partial: 'posts/shared/posts', locals: { posts: @posts }, formats: [:html]
    #   end
    # end
  end


  # GET /posts/1 or /posts/1.json
  def show
    @post = Post.friendly.find(params[:post_id])
    # Optionally, you can check if the slug matches for SEO or redirect purposes
  end

  # GET /posts/new
  def new
    if params[:cliq_id]
      @cliq = Cliq.find(params[:cliq_id])
    else
      @error = "Error"
    end
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
    @post = Post.find(params[:id])
    @cliq = @post.cliq
  end

  # POST /posts or /posts.json
  def create
    @post = Post.new(post_params)
    @post.user = current_user
    @post.cliq = Cliq.find(params[:post][:cliq_id]) if params[:post][:cliq_id]

    if @post.save
      respond_to do |format|
        format.turbo_stream do
          # Render the full `show` view, not a partial
          render turbo_stream: turbo_stream.replace('main_content', template: 'posts/show')
        end
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    @post = Post.friendly.find(params[:id]) 
    if @post.update(post_params)
      respond_to do |format|
        format.turbo_stream do
          # Render the full `show` view, not a partial
          render turbo_stream: turbo_stream.replace('main_content', template: 'posts/show')
        end
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy

    respond_to do |format|
      format.html { redirect_to posts_path, status: :see_other, notice: "Post was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.friendly.find(params[:id]) 
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:title, :content, :cliq_id, :user_id)
    end

end

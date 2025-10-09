class PostsController < ApplicationController
  # before_action :set_post, only: %i[ show edit update destroy ]
  before_action :authenticate_user!, only: [:new, :create]

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
    @replies = @post.replies.order(created_at: :desc)
  end

  # GET /posts/new
  def new
    @cliq = Cliq.find_by(id: params[:cliq_id]) if params[:cliq_id].present?
    @post = Post.new(post_type: (params[:post_type].presence || :discussion))
  
    # Important: always render the full template so the response contains the frame
    render :new
  end

  # GET /posts/1/edit
  def edit
    authorize @post = Post.find(params[:id])
    @cliq = @post.cliq
  end

  def soft_delete
    @post = Post.find(params[:id])
    # If you use Pundit, uncomment:
    # authorize @post
  
    @post.update!(deleted: true)
  
    target = post_id_slug_post_path(post_id: @post.id, slug: @post.slug)
    respond_to do |format|
      format.html        { redirect_to target, notice: I18n.t("posts.deleted_notice") }
      format.turbo_stream { redirect_to target, status: :see_other }
    end
  end

  # POST /posts or /posts.json
  def create
    @post = Post.new(post_params.except(:new_cliq_name, :new_cliq_parent_id))
    @post.user = current_user
    @post.post_type ||= :discussion

    new_name = post_params[:new_cliq_name].to_s.strip
    parent   = post_params[:new_cliq_parent_id].present? ? Cliq.find_by(id: post_params[:new_cliq_parent_id]) : nil
  
    if new_name.present?
      # Duplicate pre-check
      if Cliq.exists?(name: new_name, parent_cliq: parent)
        @parent_cliq = parent
        msg = "Cliq “#{new_name}” already exists under #{parent ? "“#{parent.name}”" : "the root"}"
        @post.errors.add(:base, msg)
        flash.now[:alert] = msg
  
        respond_to do |format|
          format.html         { render 'cliqs/new', status: :unprocessable_entity }
          format.turbo_stream { render 'cliqs/new', status: :unprocessable_entity }
        end
        return
      end
  
      ActiveRecord::Base.transaction do
        cliq = Cliq.new(name: new_name, parent_cliq: parent)
        unless cliq.save
          @parent_cliq = parent
          msg = cliq.errors.full_messages.to_sentence
          @post.errors.add(:base, msg)
          flash.now[:alert] = msg
          raise ActiveRecord::RecordInvalid, @post
        end
  
        @post.cliq = cliq
        @post.save!
      end
    else
      if @post.cliq_id.blank? || !Cliq.exists?(@post.cliq_id)
        @cliq = Cliq.find_by(id: post_params[:cliq_id])
        msg = "Please choose a cliq or create a new one."
        @post.errors.add(:cliq, msg)
        flash.now[:alert] = msg
  
        respond_to do |format|
          format.html         { render :new, status: :unprocessable_entity }
          format.turbo_stream { render :new, status: :unprocessable_entity }
        end
        return
      end
  
      ActiveRecord::Base.transaction { @post.save! }
    end
  
    target = post_id_slug_post_path(post_id: @post.id, slug: @post.slug)
    respond_to do |format|
      format.html         { redirect_to target, notice: "Post created." }
      format.turbo_stream { redirect_to target, status: :see_other }
      format.json         { render :show, status: :created, location: target }
    end
  rescue ActiveRecord::RecordInvalid
    if new_name.present?
      @parent_cliq = parent
      render 'cliqs/new', status: :unprocessable_entity
    else
      @cliq = @post.cliq || Cliq.find_by(id: post_params[:cliq_id])
      render :new, status: :unprocessable_entity
    end
  end
  

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    @post = Post.friendly.find(params[:id])
  
    if @post.update(post_params)
      # Ensure replies are available for the show template
      @replies = @post.replies.order(created_at: :desc)
  
      respond_to do |format|
        # Turbo edit -> replace main_content with the full show view (now with replies)
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace('main_content', template: 'posts/show')
        end
  
        # Non-Turbo / HTML edit -> go to the canonical post URL
        format.html do
          target = post_id_slug_post_path(post_id: @post.id, slug: @post.slug)
          redirect_to target, notice: "Post updated."
        end
  
        # Optional JSON
        format.json { render :show, status: :ok, location: @post }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :edit, status: :unprocessable_entity }
        format.html         { render :edit, status: :unprocessable_entity }
        format.json         { render json: @post.errors, status: :unprocessable_entity }
      end
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
      params.require(:post).permit(
        :title, :content, :cliq_id,
        :new_cliq_name, :new_cliq_parent_id,
        :post_type  # ← allow user to choose type
      )
    end
    
end

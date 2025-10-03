class CliqsController < ApplicationController
  before_action :set_cliq, only: %i[ show edit update destroy]
  before_action :authenticate_user!, only: [:new, :create]
  
  def index
    #change this to a cliq search page
    @cliq = Cliq.find_by(parent_cliq_id: nil)
    @pagy, @posts = pagy(Post.all.ordered)
    respond_to do |format|
      format.html # For regular page load
      format.turbo_stream # For infinite scrolling via Turbo Stream
    end
  end

  # GET /cliqs/slug or /cliqs/1.json
  def show
    cliq_ids = @cliq.self_and_descendant_ids rescue [@cliq.id]
  
    base = Post.where(cliq_id: cliq_ids)
               .left_joins(:replies)        # bring in replies for MAX()
               .group('posts.id')           # needed for the aggregate
               .includes(:user, :cliq)
               .reorder(nil)                # IMPORTANT: clear any prior ORDERs (e.g., from scopes)
  
    # Order by “latest activity” (newest reply OR post creation if no replies)
    order_expr = 'GREATEST(posts.created_at, COALESCE(MAX(replies.created_at), posts.created_at)) DESC'
  
    @pagy, @posts = pagy(base.order(Arel.sql(order_expr)))
  
    respond_to do |f|
      f.html
      f.turbo_stream
    end
  end
  
  # GET /cliqs/new
  def new
    # Parent cliq context (optional)
    @parent_cliq = Cliq.find_by(id: params[:parent_cliq_id])
    @post = Post.new
  end

  def search
    query = cliq_params[:name] # Use strong parameters for security
    if query.blank?
      render turbo_stream: turbo_stream.replace("cliq-search-results", partial: "cliqs/no_results")
    else
      @cliqs = Cliq.search(query)
      respond_to do |format|
        format.turbo_stream
      end
    end
  end

  def all
    # Exclude the top-level root Cliq that has parent_cliq_id: nil and no children
    @root_cliq = Cliq.find_by(parent_cliq_id: nil)

    @main_categories = Cliq.where(parent_cliq_id: @root_cliq.id).includes(child_cliqs: { child_cliqs: { child_cliqs: :child_cliqs } })
  end

  # GET /cliqs/1/edit
  def edit
  end

  # POST /cliqs or /cliqs.json
  def create
    @cliq = Cliq.new(cliq_params)
    @parent_cliq = @cliq.parent_cliq
  
    if @cliq.save
      respond_to do |format|
        format.html        { redirect_to cliq_path(@cliq), notice: "Cliq created." }
        format.turbo_stream { redirect_to cliq_path(@cliq), status: :see_other }
        format.json        { render :show, status: :created, location: @cliq }
      end
    else
      respond_to do |format|
        format.html         { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :new, status: :unprocessable_entity }
        format.json         { render json: @cliq.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cliqs/1 or /cliqs/1.json
  def update
    if @cliq.update(cliq_params)
      redirect_to cliqs_path, notice: "Cliq was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /cliqs/1 or /cliqs/1.json
  def destroy
    @cliq.destroy

    respond_to do |format|
      format.html { redirect_to cliqs_path, status: :see_other, notice: "Cliq was successfully destroyed." }
      format.turbo_stream
    end
  end

  private
  # infinite scrolling ---- 
  def posts_list_target
    params.fetch(:turbo_target, "posts")
  end

  def page
    params.fetch(:page, 1).to_i
  end

  def posts_scope
    if Current.user&.role_admin?
      Post.ordered
    else
      Post.ordered
    end
  end

  # end infinite scrolling ---- 


    # Use callbacks to share common setup or constraints between actions.
    def set_cliq
      if params[:id]
        @cliq = Cliq.friendly.find(params[:id])
      else
        @cliq = Cliq.find_by(parent_cliq_id: nil)
      end
    end

    # Only allow a list of trusted parameters through.
    def cliq_params
      params.require(:cliq).permit(:name, :slug, :description, :parent_cliq_id, :cliq) # Replace :attribute1, etc., with actual attribute names of Cliq model
    end
end

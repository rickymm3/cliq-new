class CliqsController < ApplicationController
  before_action :set_cliq, only: %i[ show edit update destroy]

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
    @parent_cliqs = get_all_parent_cliqs(@cliq)
    if params[:id]
      cliq_ids = @cliq.self_and_descendant_ids
      # Preload user for each post to display author info without N+1 queries
      @pagy, @posts = pagy(Post.includes(:user).where(cliq_id: cliq_ids).ordered)  # <-- changed
    else
      # Also include user for non-nested scenario
      @pagy, @posts = pagy(Post.includes(:user).ordered)  # <-- changed
    end
    respond_to do |format|
      format.html # Regular HTML response for initial load or non-Turbo requests
      format.turbo_stream # Optional, if you want to handle updates via Turbo Stream
    end
  end

  # GET /cliqs/new
  def new
    @cliq = Cliq.new
    @parent_cliq = Cliq.find_by(id: params[:parent_cliq_id]) if params[:parent_cliq_id]
    respond_to do |format|
      format.html # Regular HTML response for initial load or non-Turbo requests
      format.turbo_stream # Optional, if you want to handle updates via Turbo Stream
    end
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
    if @cliq.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to cliq_path(@cliq), notice: 'Cliq was successfully created.' }
      end
    else
      render :new, status: :unprocessable_entity
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

    def get_all_parent_cliqs(cliq)
      parents = []
      current = cliq
      while current.parent_cliq
        current = current.parent_cliq
        break if current == Cliq.where(name:"Cliq").first
        parents << current
      end
      parents.reverse # To have the direct parent first
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

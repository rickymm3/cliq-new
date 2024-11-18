class CliqsController < ApplicationController
  before_action :set_cliq, only: %i[ show edit update destroy ]

  # GET /cliqs or /cliqs.json

  # def index
  #   @cliq = Cliq.find_by(parent_cliq_id: nil)
  #   @posts = Post.all.order(created_at: :desc).page(params[:page]).per(5)
  # end

  def index
    @cliq = Cliq.find_by(parent_cliq_id: nil)
    @pagy, @posts = pagy(Post.ordered, items: 5)
    respond_to do |format|
      format.html # For regular page load
      format.turbo_stream # For infinite scrolling via Turbo Stream
    end
  end

  # GET /cliqs/slug or /cliqs/1.json
  def show
    @cliq = set_cliq if params[:id]
    @parent_cliqs = get_all_parent_cliqs(@cliq)
    if params[:id]
      cliq_ids = @cliq.self_and_descendant_ids
      @pagy, @posts = pagy(Post.where(cliq_id: cliq_ids).ordered)
    end
    # if @cliq.parent_cliq_id != @root_category.id
    #   @parent_cliqs = get_all_parent_cliqs(@cliq)
    # end
    if @cliq.nil?
      render file: "#{Rails.root}/public/404.html", status: :not_found
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
    @cliqs = Cliq.where('name ILIKE ?', "%#{params[:name]}%").order(created_at: :desc)
    respond_to do |format|
      format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("search_results",
            partial: "cliqs/search_results",
            locals: { cliqs: @cliqs })
          ]
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
      Cliq.friendly.find(params[:id]) # Use this if 'entertainment' is a slug
    end

    # Only allow a list of trusted parameters through.
    def cliq_params
      params.require(:cliq).permit(:name, :slug, :description, :parent_cliq_id) # Replace :attribute1, etc., with actual attribute names of Cliq model
    end
end

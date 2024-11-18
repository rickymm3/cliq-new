class HomeController < ApplicationController
  def index
    # @cliqs = Cliq.all # o-o-o edit this to only show the default posts eventually
    @posts = Post.all.order(created_at: :desc).page(params[:page]).per(10)
    # @cliq = Cliq.new  # This line is needed if your render uses 'cliq' as a local
    set_page_cliq
  end
end

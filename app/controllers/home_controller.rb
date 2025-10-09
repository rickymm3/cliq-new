class HomeController < ApplicationController
  def index
    base = Post.ordered.includes(:user, :cliq)
    @pagy, @posts = pagy(base)
    set_page_cliq
  end
end

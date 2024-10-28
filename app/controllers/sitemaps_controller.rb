class SitemapsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show]

  def show
    @articles = BlogApp::Article.all

    respond_to do |format|
      format.xml
    end
  end
end

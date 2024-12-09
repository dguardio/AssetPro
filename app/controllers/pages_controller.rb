class PagesController < ApplicationController
  layout 'auth'
  skip_before_action :authenticate_user!, only: [:home, :about, :contact]

  def home
    authorize :page, :home?
  end

  def about
    authorize :page, :about?
  end

  def contact
    authorize :page, :contact?
  end
end 
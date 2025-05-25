class PagesController < ApplicationController
  def home = render Views::Pages::Home.new
end

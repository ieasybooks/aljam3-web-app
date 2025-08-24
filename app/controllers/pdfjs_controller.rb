class PdfjsController < ApplicationController
  layout false

  def iframe = render Components::PdfjsIframe.new
end

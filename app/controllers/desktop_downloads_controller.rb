class DesktopDownloadsController < ApplicationController
  def show
    redirect_to DesktopRelease.download_url(params[:platform]), allow_other_host: true
  end
end

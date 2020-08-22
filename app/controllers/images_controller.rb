class ImagesController < ApplicationController
  # GET /images/1
  def show
    @image = Image.find(params[:id])
    send_data @image.body, filename: @image.filename
  end
end

class  Api::V1::ImagesController < ApplicationController
  before_action :set_note

  # POST /images
  def create
    # Create a new image with the associated note
    @image = @note.images.build
    @image.file.attach(params[:file])

    if @image.save
      # Return the image URL to be used in the frontend
      render json: { url: url_for(@image.file) }, status: :created
    else
      render json: @image.errors, status: :unprocessable_entity
    end
  end

  # GET /images (Load all images for the note)
  def index
    @images = @note.images
    render json: @images.map { |image| { name: image.file.filename.to_s, url: url_for(image.file) } }
  end

  private

  def set_note
    @note = NoteApp::Note.find(params[:note_id])
  end
end

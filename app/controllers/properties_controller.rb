class PropertiesController < ApplicationController
  before_action :set_property, only: %i[show edit update destroy]

  # static photo lists
  INTERIOR_PHOTOS = [
    "https://images.rentable.co/125174/72525196/large.jpeg",
    "https://images.rentable.co/125174/72526105/large.jpeg",
    "https://images.rentable.co/102207/82056855/large.jpeg",
    "https://images.rentable.co/125174/72527744/large.jpeg"
  ].freeze

  EXTERIOR_PHOTOS = [
    "https://images.rentable.co/125174/72525707/large.jpeg",
    "https://images.rentable.co/102207/82630648/large.jpeg",
    "https://images.rentable.co/102207/77019634/large.jpeg",
    "https://images.rentable.co/102207/88573201/large.jpeg"
  ].freeze

  # GET /properties or /properties.json
  def index
    @properties = Property.all
  end

  # GET /properties/1 or /properties/1.json
  def show
    @property = Property.find(params[:id])

    # default to "interior" if param is missing or invalid
    view = params[:images].to_s.downcase
    view = %w[interior exterior].include?(view) ? view : "interior"

    @images = (view == "exterior" ? EXTERIOR_PHOTOS : INTERIOR_PHOTOS)
  end

  # GET /properties/new
  def new
    ImportPropertiesJob.perform_later
    redirect_to properties_path, notice: 'Import started!'

    # @property = Property.new
  end

  # GET /properties/1/edit
  def edit
  end

  # POST /properties or /properties.json
  def create
    @property = Property.new(property_params)

    respond_to do |format|
      if @property.save
        format.html { redirect_to @property, notice: "Property was successfully created." }
        format.json { render :show, status: :created, location: @property }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @property.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /properties/1 or /properties/1.json
  def update
    respond_to do |format|
      if @property.update(property_params)
        format.html { redirect_to @property, notice: 'Property was successfully updated.' }
        format.json { render :show, status: :ok, location: @property }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @property.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /properties/1 or /properties/1.json
  def destroy
    @property.destroy!

    respond_to do |format|
      format.html { redirect_to properties_path, status: :see_other, notice: 'Property was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_property
    @property = Property.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def property_params
    params.require(:property).permit(:property_id, :name, :email, :unit_bedrooms)
  end
end

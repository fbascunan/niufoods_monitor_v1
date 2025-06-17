class RestaurantsController < ApplicationController
  def index
    @restaurants = Restaurant.all.includes(:devices).order(name: :asc)
  end


  def show
    @restaurant = Restaurant.includes(:devices).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurants_path, alert: "Restaurant not found"
  end
end

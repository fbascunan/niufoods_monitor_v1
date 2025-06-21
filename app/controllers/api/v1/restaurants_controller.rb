module Api
  module V1
    class RestaurantsController < ApplicationController
      def index
        restaurants = Restaurant.includes(:devices).all.order(name: :asc)
        render json: restaurants.as_json(include: { devices: { only: [:id, :name, :device_type, :model, :serial_number, :status] } }, except: [:created_at, :updated_at])
      end
    end
  end
end 
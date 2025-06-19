class RestaurantsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "restaurants_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end

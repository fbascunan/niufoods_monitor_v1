# == Schema Information
#
# Table name: restaurants
#
#  id         :bigint           not null, primary key
#  address    :string
#  email      :string
#  location   :string
#  name       :string           not null
#  phone      :string
#  status     :string
#  timezone   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_restaurants_on_name  (name) UNIQUE
#
require "test_helper"

class RestaurantTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

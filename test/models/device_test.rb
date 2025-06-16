# == Schema Information
#
# Table name: devices
#
#  id               :bigint           not null, primary key
#  device_type      :string           not null
#  last_check_in_at :datetime
#  status           :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  restaurant_id    :bigint           not null
#
# Indexes
#
#  index_devices_on_restaurant_id  (restaurant_id)
#
# Foreign Keys
#
#  fk_rails_...  (restaurant_id => restaurants.id)
#
require "test_helper"

class DeviceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

# == Schema Information
#
# Table name: maintenance_logs
#
#  id           :bigint           not null, primary key
#  description  :text
#  performed_at :datetime         not null
#  status       :string           default("pending")
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  device_id    :bigint           not null
#
# Indexes
#
#  index_maintenance_logs_on_device_id                   (device_id)
#  index_maintenance_logs_on_device_id_and_performed_at  (device_id,performed_at DESC)
#  index_maintenance_logs_on_performed_at                (performed_at)
#
# Foreign Keys
#
#  fk_rails_...  (device_id => devices.id)
#
require "test_helper"

class MaintenanceLogTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

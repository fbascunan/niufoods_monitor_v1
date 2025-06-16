require "test_helper"

module Api
  module V1
    class DevicesControllerTest < ActionDispatch::IntegrationTest
      test "should update device status" do
        device = devices(:pos_terminal_1)
        
        assert_enqueued_with(job: DeviceStatusJob) do
          put api_v1_device_path(device), params: { device: { status: "any_status" } }
        end
        
        assert_response :ok
        assert_equal "Device status updated", JSON.parse(@response.body)["message"]
      end

      test "should return not found for non-existent device" do
        put api_v1_device_path(0), params: { device: { status: "online" } }
        
        assert_response :not_found
        assert_equal "Device not found", JSON.parse(@response.body)["error"]
      end
    end
  end
end 
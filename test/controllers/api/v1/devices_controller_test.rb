require "test_helper"

module Api
  module V1
    class DevicesControllerTest < ActionDispatch::IntegrationTest
      def setup
        @device = devices(:pos_terminal_1)
        @restaurant = @device.restaurant
      end

      test "should update device status using use case" do
        assert_enqueued_with(job: WebsocketBroadcastJob, at: 5.seconds.from_now) do
          post api_v1_devices_status_path, params: { 
            device: { 
              serial_number: @device.serial_number,
              status: "active",
              description: "Test update",
              device_type: "pos"
            } 
          }
        end
        
        assert_response :ok
        response_body = JSON.parse(@response.body)
        assert_equal "Device status updated successfully. WebSocket update will be broadcast in 5 seconds.", response_body["message"]
        assert_equal @device.id, response_body["device"]["id"]
        assert_equal @device.serial_number, response_body["device"]["serial_number"]
      end

      test "should return not found for non-existent device" do
        post api_v1_devices_status_path, params: { 
          device: { 
            serial_number: "NONEXISTENT",
            status: "active" 
          } 
        }
        
        assert_response :not_found
        assert_equal "Device not found", JSON.parse(@response.body)["error"]
      end

      test "should handle use case failure gracefully" do
        # Mock the use case to return false
        use_case_mock = mock
        use_case_mock.expects(:call).returns(false)
        DeviceMonitoring::UpdateDeviceStatus.expects(:new).returns(use_case_mock)
        
        post api_v1_devices_status_path, params: { 
          device: { 
            serial_number: @device.serial_number,
            status: "active",
            description: "Test update"
          } 
        }
        
        assert_response :unprocessable_entity
        assert_equal "Failed to update device status", JSON.parse(@response.body)["error"]
      end

      test "should schedule websocket broadcast job with correct parameters" do
        old_restaurant_status = @restaurant.status
        
        assert_enqueued_with(job: WebsocketBroadcastJob, at: 5.seconds.from_now) do
          post api_v1_devices_status_path, params: { 
            device: { 
              serial_number: @device.serial_number,
              status: "active",
              description: "Test update"
            } 
          }
        end
        
        # Check that the job was enqueued with correct arguments
        assert_enqueued_jobs 1, only: WebsocketBroadcastJob
        enqueued_job = ActiveJob::Base.queue_adapter.enqueued_jobs.last
        assert_equal @restaurant.id, enqueued_job[:args][0]
        assert_equal old_restaurant_status, enqueued_job[:args][1]
      end

      test "should handle invalid status parameter" do
        post api_v1_devices_status_path, params: { 
          device: { 
            serial_number: @device.serial_number,
            status: "invalid_status",
            description: "Test update"
          } 
        }
        
        assert_response :unprocessable_entity
        response_body = JSON.parse(@response.body)
        assert_equal "Failed to update device status", response_body["error"]
      end

      test "should handle missing status parameter" do
        post api_v1_devices_status_path, params: { 
          device: { 
            serial_number: @device.serial_number,
            description: "Test update"
          } 
        }
        
        assert_response :unprocessable_entity
        response_body = JSON.parse(@response.body)
        assert_equal "Failed to update device status", response_body["error"]
      end

      test "should handle empty device parameters" do
        post api_v1_devices_status_path, params: { device: {} }
        
        assert_response :unprocessable_entity
        response_body = JSON.parse(@response.body)
        assert_equal "Failed to update device status", response_body["error"]
      end

      test "should handle malformed JSON" do
        post api_v1_devices_status_path, 
            params: "invalid json",
            headers: { 'CONTENT_TYPE' => 'application/json' }
        
        assert_response :bad_request
      end

      test "should update device with all valid parameters" do
        post api_v1_devices_status_path, params: { 
          device: { 
            serial_number: @device.serial_number,
            status: "warning",
            description: "Device showing warning signs",
            device_type: "printer",
            last_check_in_at: Time.current
          } 
        }
        
        assert_response :ok
        response_body = JSON.parse(@response.body)
        assert_equal "Device status updated successfully. WebSocket update will be broadcast in 5 seconds.", response_body["message"]
      end

      test "should handle critical status update" do
        post api_v1_devices_status_path, params: { 
          device: { 
            serial_number: @device.serial_number,
            status: "critical",
            description: "Critical device failure"
          } 
        }
        
        assert_response :ok
        response_body = JSON.parse(@response.body)
        assert_equal "Device status updated successfully. WebSocket update will be broadcast in 5 seconds.", response_body["message"]
      end

      test "should handle inactive status update" do
        post api_v1_devices_status_path, params: { 
          device: { 
            serial_number: @device.serial_number,
            status: "inactive",
            description: "Device deactivated"
          } 
        }
        
        assert_response :ok
        response_body = JSON.parse(@response.body)
        assert_equal "Device status updated successfully. WebSocket update will be broadcast in 5 seconds.", response_body["message"]
      end
    end
  end
end 
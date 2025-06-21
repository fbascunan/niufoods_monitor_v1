require "test_helper"

class ApiDevicesTest < ActionDispatch::IntegrationTest
  def setup
    @device = devices(:pos_terminal_1)
    @restaurant = @device.restaurant
  end

  test "should update device status via API" do
    put api_v1_device_path(@device), params: { 
      device: { 
        status: "activo",
        description: "Device is working properly"
      } 
    }
    
    assert_response :ok
    response_body = JSON.parse(@response.body)
    assert_equal "Device status updated successfully. WebSocket update will be broadcast in 5 seconds.", response_body["message"]
    assert_equal @device.id, response_body["device"]["id"]
  end

  test "should handle device status update with all parameters" do
    put api_v1_device_path(@device), params: { 
      device: { 
        status: "advertencia",
        description: "Device showing warning signs",
        device_type: "printer",
        last_check_in_at: Time.current.iso8601
      } 
    }
    
    assert_response :ok
    response_body = JSON.parse(@response.body)
    assert_equal "Device status updated successfully. WebSocket update will be broadcast in 5 seconds.", response_body["message"]
  end

  test "should return 404 for non-existent device" do
    put api_v1_device_path(999999), params: { 
      device: { 
        status: "activo",
        description: "Test update"
      } 
    }
    
    assert_response :not_found
    response_body = JSON.parse(@response.body)
    assert_equal "Device not found", response_body["error"]
  end

  test "should handle invalid status parameter" do
    put api_v1_device_path(@device), params: { 
      device: { 
        status: "invalid_status",
        description: "Test update"
      } 
    }
    
    assert_response :unprocessable_entity
    response_body = JSON.parse(@response.body)
    assert_equal "Failed to update device status", response_body["error"]
  end

  test "should handle missing status parameter" do
    put api_v1_device_path(@device), params: { 
      device: { 
        description: "Test update without status"
      } 
    }
    
    assert_response :unprocessable_entity
    response_body = JSON.parse(@response.body)
    assert_equal "Failed to update device status", response_body["error"]
  end

  test "should handle empty request body" do
    put api_v1_device_path(@device), params: {}
    
    assert_response :unprocessable_entity
    response_body = JSON.parse(@response.body)
    assert_equal "Failed to update device status", response_body["error"]
  end

  test "should handle malformed JSON" do
    put api_v1_device_path(@device), 
        params: "invalid json",
        headers: { 'CONTENT_TYPE' => 'application/json' }
    
    assert_response :bad_request
  end

  test "should update device status to critical" do
    put api_v1_device_path(@device), params: { 
      device: { 
        status: "critico",
        description: "Critical device failure detected"
      } 
    }
    
    assert_response :ok
    response_body = JSON.parse(@response.body)
    assert_equal "Device status updated successfully. WebSocket update will be broadcast in 5 seconds.", response_body["message"]
  end

  test "should update device status to inactive" do
    put api_v1_device_path(@device), params: { 
      device: { 
        status: "inactivo",
        description: "Device deactivated"
      } 
    }
    
    assert_response :ok
    response_body = JSON.parse(@response.body)
    assert_equal "Device status updated successfully. WebSocket update will be broadcast in 5 seconds.", response_body["message"]
  end

  test "should schedule websocket broadcast job" do
    assert_enqueued_with(job: WebsocketBroadcastJob, wait: 5.seconds) do
      put api_v1_device_path(@device), params: { 
        device: { 
          status: "activo",
          description: "Test update"
        } 
      }
    end
    
    assert_enqueued_jobs 1, only: WebsocketBroadcastJob
  end

  test "should handle concurrent status updates" do
    threads = []
    3.times do |i|
      threads << Thread.new do
        put api_v1_device_path(@device), params: { 
          device: { 
            status: "activo",
            description: "Concurrent update #{i}"
          } 
        }
      end
    end
    
    threads.each(&:join)
    
    # All requests should succeed
    assert_equal 3, @device.maintenance_logs.count
  end

  test "should validate device type parameter" do
    put api_v1_device_path(@device), params: { 
      device: { 
        status: "activo",
        device_type: "invalid_type",
        description: "Test update"
      } 
    }
    
    assert_response :unprocessable_entity
    response_body = JSON.parse(@response.body)
    assert_equal "Failed to update device status", response_body["error"]
  end

  test "should handle large description text" do
    large_description = "A" * 1000
    put api_v1_device_path(@device), params: { 
      device: { 
        status: "activo",
        description: large_description
      } 
    }
    
    assert_response :ok
    response_body = JSON.parse(@response.body)
    assert_equal "Device status updated successfully. WebSocket update will be broadcast in 5 seconds.", response_body["message"]
  end
end 
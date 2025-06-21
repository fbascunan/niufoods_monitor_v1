require "test_helper"

class ApiDevicesTest < ActionDispatch::IntegrationTest
  def setup
    @device = devices(:pos_terminal_1)
    @restaurant = @device.restaurant
  end

  test "should update device status via API with serial number" do
    post api_v1_devices_status_path, params: { 
      device: { 
        serial_number: @device.serial_number,
        status: "active",
        description: "Device is working properly"
      } 
    }
    
    assert_response :ok
    response_body = JSON.parse(@response.body)
    assert_equal "Device status updated successfully. WebSocket update will be broadcast in 5 seconds.", response_body["message"]
    assert_equal @device.id, response_body["device"]["id"]
    assert_equal @device.serial_number, response_body["device"]["serial_number"]
  end

  test "should handle device status update with all parameters" do
    post api_v1_devices_status_path, params: { 
      device: { 
        serial_number: @device.serial_number,
        status: "warning",
        description: "Device showing warning signs",
        device_type: "printer",
        name: "Updated Device Name"
      } 
    }
    
    assert_response :ok
    response_body = JSON.parse(@response.body)
    assert_equal "Device status updated successfully. WebSocket update will be broadcast in 5 seconds.", response_body["message"]
  end

  test "should return 404 for non-existent device serial number" do
    post api_v1_devices_status_path, params: { 
      device: { 
        serial_number: "NONEXISTENT123",
        status: "active",
        description: "Test update"
      } 
    }
    
    assert_response :not_found
    response_body = JSON.parse(@response.body)
    assert_equal "Device not found", response_body["error"]
    assert_equal "NONEXISTENT123", response_body["serial_number"]
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

  test "should handle missing serial number parameter" do
    post api_v1_devices_status_path, params: { 
      device: { 
        status: "active",
        description: "Test update without serial number"
      } 
    }
    
    assert_response :not_found
    response_body = JSON.parse(@response.body)
    assert_equal "Device not found", response_body["error"]
  end

  test "should handle missing status parameter" do
    post api_v1_devices_status_path, params: { 
      device: { 
        serial_number: @device.serial_number,
        description: "Test update without status"
      } 
    }
    
    assert_response :unprocessable_entity
    response_body = JSON.parse(@response.body)
    assert_equal "Failed to update device status", response_body["error"]
  end

  test "should handle empty request body" do
    post api_v1_devices_status_path, params: {}
    
    assert_response :unprocessable_entity
    response_body = JSON.parse(@response.body)
    assert_equal "Failed to update device status", response_body["error"]
  end

  test "should update device status to critical" do
    post api_v1_devices_status_path, params: { 
      device: { 
        serial_number: @device.serial_number,
        status: "critical",
        description: "Critical device failure detected"
      } 
    }
    
    assert_response :ok
    response_body = JSON.parse(@response.body)
    assert_equal "Device status updated successfully. WebSocket update will be broadcast in 5 seconds.", response_body["message"]
  end

  test "should update device status to inactive" do
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

  test "should schedule websocket broadcast job" do
    assert_enqueued_with(job: WebsocketBroadcastJob) do
      post api_v1_devices_status_path, params: { 
        device: { 
          serial_number: @device.serial_number,
          status: "active",
          description: "Test update"
        } 
      }
    end
    
    assert_enqueued_jobs 1, only: WebsocketBroadcastJob
  end

  test "should validate device type parameter" do
    post api_v1_devices_status_path, params: { 
      device: { 
        serial_number: @device.serial_number,
        status: "active",
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
    post api_v1_devices_status_path, params: { 
      device: { 
        serial_number: @device.serial_number,
        status: "active",
        description: large_description
      } 
    }
    
    assert_response :ok
    response_body = JSON.parse(@response.body)
    assert_equal "Device status updated successfully. WebSocket update will be broadcast in 5 seconds.", response_body["message"]
  end

  test "should update device with different device types" do
    %w[pos printer network].each do |device_type|
      post api_v1_devices_status_path, params: { 
        device: { 
          serial_number: @device.serial_number,
          status: "active",
          device_type: device_type,
          description: "Testing #{device_type} device type"
        } 
      }
      
      assert_response :ok
    end
  end

  test "should handle malformed JSON" do
    post api_v1_devices_status_path, 
         params: "invalid json",
         headers: { 'CONTENT_TYPE' => 'application/json' }
    
    assert_response :bad_request
  end
end 
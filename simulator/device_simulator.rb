require 'uri'
require 'net/http'
require 'json'
require 'pry'

DEVICE_STATUS_MAP = {
  "1" => "operational",
  "2" => "maintenance",
  "3" => "failing"
}

def simulate_device_status(device_id, status)
  url = URI("http://0.0.0.0:5000/api/v1/devices/#{device_id}")
  http = Net::HTTP.new(url.host, url.port)
  request = Net::HTTP::Put.new(url)
  request["Content-Type"] = "application/json"
  request.body = { device: { status: status } }.to_json
  
  begin
    response = http.request(request)
    puts "Status Code: #{response.code}"
    puts "Response Headers: #{response.to_hash}"
    puts "Response Body: #{response.read_body}"
  rescue => e
    puts "Error occurred: #{e.message}"
    puts e.backtrace
  end
end

simulate_device_status("1", "failing")
simulate_device_status("2", "maintenance")
simulate_device_status("3", "operational")

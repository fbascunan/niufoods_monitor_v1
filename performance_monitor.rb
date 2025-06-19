#!/usr/bin/env ruby

# Simple performance monitoring script for the NiuFoods monitoring system
# Run this in a separate terminal to monitor WebSocket activity

require 'redis'
require 'json'
require 'time'

class PerformanceMonitor
  def initialize
    @redis = Redis.new(url: ENV.fetch('REDIS_URL', 'redis://localhost:6379'))
    @message_count = 0
    @start_time = Time.now
  end

  def monitor_websocket_activity
    puts "🔍 Starting WebSocket Performance Monitor..."
    puts "📊 Monitoring Redis pub/sub activity..."
    puts "⏰ Started at: #{@start_time.strftime('%Y-%m-%d %H:%M:%S')}"
    puts "=" * 60

    loop do
      begin
        # Get Redis info to monitor memory usage
        info = @redis.info
        memory_usage = info['used_memory_human']
        connected_clients = info['connected_clients']
        
        # Calculate messages per second
        elapsed = Time.now - @start_time
        messages_per_second = @message_count / elapsed.to_f
        
        # Clear screen and show stats
        system('clear') || system('cls')
        puts "🔍 WebSocket Performance Monitor"
        puts "=" * 60
        puts "⏰ Runtime: #{format_duration(elapsed)}"
        puts "📨 Total Messages: #{@message_count}"
        puts "⚡ Messages/Second: #{messages_per_second.round(2)}"
        puts "💾 Redis Memory: #{memory_usage}"
        puts "👥 Connected Clients: #{connected_clients}"
        puts "=" * 60
        puts "Press Ctrl+C to stop monitoring"
        
        sleep 2
      rescue => e
        puts "❌ Error monitoring: #{e.message}"
        sleep 5
      end
    end
  end

  private

  def format_duration(seconds)
    hours = (seconds / 3600).to_i
    minutes = ((seconds % 3600) / 60).to_i
    secs = (seconds % 60).to_i
    
    if hours > 0
      "#{hours}h #{minutes}m #{secs}s"
    elsif minutes > 0
      "#{minutes}m #{secs}s"
    else
      "#{secs}s"
    end
  end
end

# Run the monitor
monitor = PerformanceMonitor.new
monitor.monitor_websocket_activity 
import consumer from "channels/consumer"

let restaurantsContainer = null;
let lastUpdateTime = 0;
const UPDATE_THROTTLE_MS = 1000; // Only process updates every 1 second

function updateConnectionStatus(connected, message) {
  const indicator = document.getElementById('status-indicator');
  const text = document.getElementById('status-text');
  
  if (indicator && text) {
    indicator.style.background = connected ? '#28a745' : '#dc3545';
    text.textContent = message;
  }
}

consumer.subscriptions.create("RestaurantsChannel", {
  connected() {
    updateConnectionStatus(true, "Connected");
    this.findRestaurantsContainer();
  },

  disconnected() {
    updateConnectionStatus(false, "Disconnected");
  },

  received(data) {
    // Throttle updates to prevent excessive processing
    const now = Date.now();
    if (now - lastUpdateTime < UPDATE_THROTTLE_MS) {
      return;
    }
    lastUpdateTime = now;
    
    // Try to find container if not already found
    if (!restaurantsContainer) {
      this.findRestaurantsContainer();
    }
    
    // Only proceed if we're on a page with the restaurants container
    if (!restaurantsContainer) {
      return;
    }
    
    try {
      if (data.type === 'device_update') {
        this.updateDeviceCard(data);
      } else {
        this.updateRestaurantCard(data);
      }
    } catch (error) {
      console.error("Error processing WebSocket update:", error);
    }
  },

  findRestaurantsContainer() {
    restaurantsContainer = document.querySelector(".restaurants-container");
  },

  updateRestaurantCard(data) {
    const existingCard = document.querySelector(`[data-restaurant-id="${data.id}"]`);
    if (existingCard) {
      // Update card class for styling
      existingCard.className = `restaurant-card ${data.status}`;
      
      // Update restaurant name
      const nameElement = existingCard.querySelector('.restaurant-info h3');
      if (nameElement) {
        nameElement.textContent = data.name;
      }
      
      // Update status badge
      const statusBadge = existingCard.querySelector('.status-badge');
      if (statusBadge) {
        statusBadge.className = `status-badge status-${data.status}`;
        statusBadge.textContent = data.status;
      }
      
      // Update device count
      const deviceCount = existingCard.querySelector('.device-count');
      if (deviceCount) {
        deviceCount.textContent = `${data.devices_count} devices`;
      }
    } else {
      // Remove "no restaurants" message if it exists
      const noRestaurantsDiv = restaurantsContainer.querySelector('.no-restaurants');
      if (noRestaurantsDiv) {
        noRestaurantsDiv.remove();
      }

      // Create new restaurant card
      const newCardHtml = `
        <div class="restaurant-card ${data.status}" data-restaurant-id="${data.id}">
          <div class="restaurant-header" onclick="toggleDevices(${data.id})">
            <div class="restaurant-info">
              <h3>${data.name}</h3>
              <p class="location">${data.location || 'Location TBD'}</p>
            </div>
            <div class="restaurant-status">
              <span class="status-badge status-${data.status}">
                ${data.status}
              </span>
              <div class="device-count">
                ${data.devices_count} devices
              </div>
              <div class="expand-icon" id="expand-${data.id}">▼</div>
            </div>
          </div>
          
          <div class="devices-section" id="devices-${data.id}" style="display: none;">
            <div class="devices-header">
              <h4>Devices</h4>
            </div>
            <div class="no-devices">
              <p>No devices found for this restaurant.</p>
            </div>
          </div>
        </div>
      `;
      
      restaurantsContainer.insertAdjacentHTML('beforeend', newCardHtml);
    }
  },

  updateDeviceCard(data) {
    const existingDeviceCard = document.querySelector(`[data-device-id="${data.device_id}"]`);
    if (existingDeviceCard) {
      // Update device card class for styling
      existingDeviceCard.className = `device-card device-${data.status}`;
      
      // Update device name
      const nameElement = existingDeviceCard.querySelector('.device-header h5');
      if (nameElement) {
        nameElement.textContent = data.name;
      }
      
      // Update device status
      const statusElement = existingDeviceCard.querySelector('.device-status');
      if (statusElement) {
        statusElement.className = `device-status status-${data.status}`;
        statusElement.textContent = data.status;
      }
      
      // Update device details
      const detailsElement = existingDeviceCard.querySelector('.device-details');
      if (detailsElement) {
        const typeElement = detailsElement.querySelector('p:nth-child(1)');
        const modelElement = detailsElement.querySelector('p:nth-child(2)');
        const serialElement = detailsElement.querySelector('p:nth-child(3)');
        const lastCheckElement = detailsElement.querySelector('p:nth-child(4)');
        
        if (typeElement) {
          typeElement.innerHTML = `<strong>Type:</strong> ${data.device_type}`;
        }
        if (modelElement) {
          modelElement.innerHTML = `<strong>Model:</strong> ${data.model || 'N/A'}`;
        }
        if (serialElement) {
          serialElement.innerHTML = `<strong>Serial:</strong> ${data.serial_number || 'N/A'}`;
        }
        if (lastCheckElement) {
          const lastCheckTime = data.last_check_in_at ? 
            new Date(data.last_check_in_at).toLocaleString() : 'Never';
          lastCheckElement.innerHTML = `<strong>Last Check:</strong> <span class="last-check-time" data-device-id="${data.device_id}">${lastCheckTime}</span>`;
        }
      }
    } else {
      // Find the devices grid for this restaurant
      const devicesGrid = document.querySelector(`#devices-${data.restaurant_id} .devices-grid`);
      if (devicesGrid) {
        // Remove "no devices" message if it exists
        const noDevicesDiv = devicesGrid.parentElement.querySelector('.no-devices');
        if (noDevicesDiv) {
          noDevicesDiv.remove();
        }
        
        // Create new device card
        const newDeviceCardHtml = `
          <div class="device-card device-${data.status}" data-device-id="${data.device_id}" data-restaurant-id="${data.restaurant_id}">
            <div class="device-header">
              <h5>${data.name}</h5>
              <span class="device-status status-${data.status}">
                ${data.status}
              </span>
            </div>
            <div class="device-details">
              <p><strong>Type:</strong> ${data.device_type}</p>
              <p><strong>Model:</strong> ${data.model || 'N/A'}</p>
              <p><strong>Serial:</strong> ${data.serial_number || 'N/A'}</p>
              <p><strong>Last Check:</strong> 
                <span class="last-check-time" data-device-id="${data.device_id}">
                  ${data.last_check_in_at ? new Date(data.last_check_in_at).toLocaleString() : 'Never'}
                </span>
              </p>
              <div class="device-actions">
                <a href="/devices/${data.device_id}" class="history-link">View History</a>
              </div>
            </div>
          </div>
        `;
        
        devicesGrid.insertAdjacentHTML('beforeend', newDeviceCardHtml);
      }
    }
  }
});

import consumer from "channels/consumer"

let restaurantsContainer = null;
let lastUpdateTime = 0;
const UPDATE_THROTTLE_MS = 10; // Process updates every 1 second

function updateConnectionStatus(connected) {
  const indicator = document.getElementById('status-indicator');
  if (indicator) {
    indicator.style.background = connected ? '#28a745' : '#dc3545';
  }
}

consumer.subscriptions.create("RestaurantsChannel", {
  connected() {
    updateConnectionStatus(true);
    this.findRestaurantsContainer();
  },

  disconnected() {
    updateConnectionStatus(false);
  },

  received(data) {
    // Throttle updates
    const now = Date.now();
    if (now - lastUpdateTime < UPDATE_THROTTLE_MS) {
      console.log("Throttling update");
      return;
    }
    lastUpdateTime = now;

    if (!restaurantsContainer) {
      this.findRestaurantsContainer();
    }
    if (!restaurantsContainer) {
      console.log("No restaurants container found");
      return;
    }

    try {
      if (data.restaurant && data.devices) {
        console.log("Updating restaurant and all devices", data.restaurant, data.devices);
        this.updateRestaurantStatus(data.restaurant);
        this.updateAllDevicesStatus(data.devices);
      }
    } catch (error) {
      console.error("Error processing WebSocket update:", error);
    }
  },

  findRestaurantsContainer() {
    restaurantsContainer = document.querySelector(".restaurants-container");
  },

  updateRestaurantStatus(restaurantData) {
    const restaurantCard = document.querySelector(`[data-restaurant-id="${restaurantData.id}"]`);
    if (!restaurantCard) {
      console.log("No restaurant card found for ID:", restaurantData.id);
      return;
    }

    // Update restaurant status badge
    const statusBadge = restaurantCard.querySelector('.status-badge');
    if (statusBadge) {
      statusBadge.className = `status-badge status-${restaurantData.status}`;
      statusBadge.textContent = restaurantData.status;
      console.log("Updated restaurant status badge", restaurantData.status, statusBadge);
    }

    // Update restaurant card class
    restaurantCard.className = `restaurant-card ${restaurantData.status}`;

    // Update device count
    const deviceCount = restaurantCard.querySelector('.device-count');
    if (deviceCount) {
      deviceCount.textContent = `${restaurantData.devices_count} devices`;
    }
  },

  updateAllDevicesStatus(devicesData) {
    devicesData.forEach(deviceData => {
      const deviceCard = document.querySelector(`[data-device-id="${deviceData.device_id}"]`);
      if (!deviceCard) return;

      // Update device status
      const statusElement = deviceCard.querySelector('.device-status');
      if (statusElement) {
        statusElement.className = `device-status status-${deviceData.status}`;
        statusElement.textContent = deviceData.status;
      }

      // Update device card class
      deviceCard.className = `device-card device-${deviceData.status}`;

      // Update last check time
      const lastCheckElement = deviceCard.querySelector('.last-check-time');
      if (lastCheckElement && deviceData.last_check_in_at) {
        const lastCheckTime = new Date(deviceData.last_check_in_at).toLocaleString();
        lastCheckElement.textContent = lastCheckTime;
      }
    });
  }
});

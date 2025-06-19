import consumer from "channels/consumer"

console.log("RestaurantsChannel connected");

let restaurantTableBody = null;
let lastUpdateTime = 0;
const UPDATE_THROTTLE_MS = 1000; // Only process updates every 1 second

consumer.subscriptions.create("RestaurantsChannel", {
  connected() {
    console.log("RestaurantsChannel connected");
    // Try to find the restaurants table
    restaurantTableBody = document.querySelector(".restaurants-table tbody");
    if (restaurantTableBody) {
      console.log("Restaurants table found");
    } else {
      console.log("Restaurants table not found on this page");
    }
  },

  disconnected() {
    console.log("RestaurantsChannel disconnected");
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Throttle updates to prevent excessive processing
    const now = Date.now();
    if (now - lastUpdateTime < UPDATE_THROTTLE_MS) {
      return;
    }
    lastUpdateTime = now;
    
    // Only proceed if we're on a page with the restaurants table
    if (!restaurantTableBody) {
      // Silently skip if not on the right page - no console log to reduce noise
      return;
    }
    
    try {
      const existingRow = document.querySelector(`tr[data-restaurant-id="${data.id}"]`);
      if (existingRow) {
        // Update row class for styling
        existingRow.className = data.status;
        
        // Update table cells safely
        const cells = existingRow.querySelectorAll('td');
        if (cells.length >= 5) {
          cells[0].textContent = data.id;
          cells[1].textContent = data.name;
          
          // Update status span
          const statusCell = cells[2];
          const statusSpan = statusCell.querySelector('span');
          if (statusSpan) {
            statusSpan.className = `status-${data.status}`;
            statusSpan.textContent = data.status;
          }
          
          cells[3].textContent = data.devices_count;
          cells[4].textContent = data.updated_ago;
        }
      } else {
        console.log("New restaurant detected, adding to table:", data.name);
        
        // Remove "no restaurants" row if it exists
        const noRestaurantsRow = restaurantTableBody.querySelector('tr td[colspan="6"]');
        if (noRestaurantsRow && noRestaurantsRow.parentElement) {
          noRestaurantsRow.parentElement.remove();
        }

        // Safely add new row
        const newRowHtml = `
          <tr data-restaurant-id="${data.id}" class="${data.status}">
            <td>${data.id}</td>
            <td>${data.name}</td>
            <td><span class="status-${data.status}">${data.status}</span></td>
            <td>${data.devices_count}</td>
            <td>${data.updated_ago}</td>
            <td><a href="/restaurants/${data.id}">View Devices</a></td>
          </tr>
        `;
        
        restaurantTableBody.insertAdjacentHTML('beforeend', newRowHtml);
      }
    } catch (error) {
      console.error("Error processing WebSocket update:", error);
    }
  }
});

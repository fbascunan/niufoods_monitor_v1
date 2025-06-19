import consumer from "channels/consumer"

console.log("RestaurantsChannel connected");

let restaurantTableBody = null;

consumer.subscriptions.create("RestaurantsChannel", {
  connected() {
    console.log("RestaurantsChannel connected");
    restaurantTableBody = document.querySelector(".restaurants-table tbody");
    console.log(restaurantTableBody);
  },

  disconnected() {
    console.log("RestaurantsChannel disconnected");
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    console.log("Received WebSocket data:", data);
    const existingRow = document.querySelector(`tr[data-restaurant-id="${data.id}"]`);
    if (existingRow) {
      // Update row class for styling
      existingRow.className = data.status;
      
      // Update table cells
      existingRow.querySelector('td:nth-child(1)').textContent = data.id;
      existingRow.querySelector('td:nth-child(2)').textContent = data.name;
      
      // Update status span
      const statusCell = existingRow.querySelector('td:nth-child(3)');
      const statusSpan = statusCell.querySelector('span');
      if (statusSpan) {
        statusSpan.className = `status-${data.status}`;
        statusSpan.textContent = data.status;
      }
      
      existingRow.querySelector('td:nth-child(4)').textContent = data.devices_count;
      existingRow.querySelector('td:nth-child(5)').textContent = data.updated_ago;
    } else {
      console.log("New restaurant detected, adding to table:", data.name);
      
      const noRestaurantsRow = restaurantTableBody.querySelector('tr td[colspan="6"]');
      if (noRestaurantsRow) {
        noRestaurantsRow.parentElement.remove();
      }

      restaurantTableBody.insertAdjacentHTML('beforeend', `
        <tr data-restaurant-id="${data.id}" class="${data.status}">
          <td>${data.id}</td>
          <td>${data.name}</td>
          <td><span class="status-${data.status}">${data.status}</span></td>
          <td>${data.devices_count}</td>
          <td>${data.updated_ago}</td>
          <td><a href="/restaurants/${data.id}">View Devices</a></td>
        </tr>
      `);
    }
  }
});

update_notification();

document.addEventListener("turbo:render", update_notification)

function update_notification() {
    const toast = document.getElementById("notification");
    const display = document.getElementById("display_notifications")

    if (display) {
        new bootstrap.Toast(toast).show();
    }
}
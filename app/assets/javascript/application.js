update_notification();

document.addEventListener("turbo:render", update_notification)
document.addEventListener("turbo:before-render", update_notification)

function update_notification() {
    const toast = document.getElementById("notification");
    const body = document.getElementById("notifications_body")

    if (body.childElementCount > 0) {
        new bootstrap.Toast(toast).show();
    }
}
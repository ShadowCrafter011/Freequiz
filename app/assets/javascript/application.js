const toast = document.getElementById("notification");
const notice = document.getElementById("notice");
const alert = document.getElementById("alert");
const success = document.getElementById("success")

if (notice?.innerHTML || alert?.innerHTML || success?.innerHTML) {
    new bootstrap.Toast(toast).show();
}
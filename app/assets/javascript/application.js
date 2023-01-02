//= require jquery3
//= require jquery_ujs

document.addEventListener("turbo:load", () => {
    if ($( "#notifications_body" ).children().length > 0) {
        new bootstrap.Toast($("#notification")).show();
    }
});
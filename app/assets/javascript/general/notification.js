$(document).on("turbo:load turbo:render", () => {
    if ($("#notifications_body").children().length > 0 && !$("#notification").hasClass("show")) {
        new bootstrap.Toast($("#notification")).show();
    }
});
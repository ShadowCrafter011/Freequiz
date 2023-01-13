$(document).on("turbo:load", () => {
    if ($("#notifications_body").children().length > 0) {
        new bootstrap.Toast($("#notification")).show();
      }
});
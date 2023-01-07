$(document).on("click", "#search-form-submit", () => {
    let value = $("#search-form-input").val();
    if (value != "") {
        Turbo.visit(`/search?query=${value}`);
    } else {
        invalidate("#search-form-input");
    }
});
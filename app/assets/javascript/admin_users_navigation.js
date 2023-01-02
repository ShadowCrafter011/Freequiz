$(document).on("click", "div[id='admin_user_cards'] div[class='card']", function(event) {
    Turbo.visit($(this).attr("href"));
});
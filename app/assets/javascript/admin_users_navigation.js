add_click_listeners();
document.addEventListener("turbo:load", add_click_listeners);

function add_click_listeners() {
    document.querySelectorAll(".card").forEach(card => {
        card.addEventListener("click", () => {
            location.href = card.dataset.href;
        });
    });
}
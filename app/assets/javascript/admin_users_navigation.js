document.querySelectorAll(".card").forEach(card => {
    card.addEventListener("click", () => {
        location.href = card.dataset.href;
    });
});
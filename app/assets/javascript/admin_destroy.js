function allConfirmed() {
    for (let element of document.querySelectorAll(".delete-btn")) {
        if (element.dataset.confirmed != "1") return false;
    }
    return true;
}

document.querySelectorAll(".delete-btn").forEach(button => {
    button.addEventListener("click", e => {
        const btn = e.target;
        if (btn.dataset.confirmed) return;

        btn.classList.toggle("btn-danger");
        btn.classList.toggle("btn-success");
        btn.innerText = "Confirmed";
        btn.dataset.confirmed = 1

        if (!allConfirmed()) {
            e.preventDefault();
        }
    });
});
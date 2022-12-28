function add_translation() {
    let translations = document.querySelector("#translations");
    translations.appendChild(document.querySelector("#template").childNodes[1].cloneNode(true));
    window.scrollTo(0, document.body.scrollHeight);
}

document.addEventListener("click", e => {
    if (e.target.classList.contains("delete-translation")) {
        e.target.parentElement.parentElement.remove();
    }
});

document.addEventListener("keypress", e => {
    if (e.key == "Enter") {
        e.preventDefault();
        add_translation();
    }
});
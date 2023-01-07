function toggle_truncate(element_id) {
    let text = document.querySelector(`#${element_id}`);
    let show_more = document.querySelector(`#${element_id}_show_more`);
    let show_less = document.querySelector(`#${element_id}_show_less`);

    toggle_display([show_less, show_more]);
    text.classList.toggle("text-truncate");
}

function toggle_display(elements) {
    elements.forEach(element => {
        if (element.style.display == "block") {
            element.style.display = "none";
        } else {
            element.style.display = "block";
        }
    });
}
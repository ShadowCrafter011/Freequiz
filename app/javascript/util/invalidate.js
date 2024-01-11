export function invalidate_element(el, timeout = 5000) {
    let element = $(el);

    if (element.hasClass("is-invalid")) return;

    element.addClass("is-invalid");
    element.data("normal", element.attr("placeholder"));
    element.attr("placeholder", element.data("error"));

    if (timeout > 0) {
        setTimeout(() => {
            element.removeClass("is-invalid");
            element.attr("placeholder", element.data("normal"));
        }, timeout);
    }
}

export function invalidate(id, timeout = 5000) {
    invalidate_element($(id), timeout);
}

function invalidate(id, timeout=5000) {
    var invalid_object = $(id);
    invalid_object.addClass("is-invalid");
    invalid_object.data("normal", invalid_object.attr("placeholder"));
    invalid_object.attr("placeholder", invalid_object.data("error"));
 
    if (timeout > 0) {
        setTimeout(() => {
            invalid_object.removeClass("is-invalid");
            invalid_object.attr("placeholder", invalid_object.data("normal"));
        }, timeout);
    }
}
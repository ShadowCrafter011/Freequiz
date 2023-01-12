$(document).on("turbo:load", function(event) {
    $("input[name='bug_report[url]']").val(event.detail.url);
});

$(document).on("submit", "form[action='/report']", function(event) {
    if (input_val("title").length < 3) {
        invalidate_element(form_child("title"));
        event.preventDefault();
    }
    if (input_val("body").length < 10) {
        invalidate_element(form_child("body"));
        event.preventDefault();
    }
});

const input_val = (name) => form_child(name).val();
const form_child = (name) => $(`form[action='/report'] #bug_report_${name}`);

function show_bug_report() {
    new bootstrap.Toast($("#bug-report")).show();
}
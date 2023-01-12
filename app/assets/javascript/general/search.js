$(document).on("click", "#search-form-submit", () => {
    check_search();
});

$(document).on("submit", "#search-form", event => {
    event.preventDefault();
    check_search();
});

function check_search() {
    if (search_value() != "") {
        Turbo.visit(search_link(search_value()));
    } else {
        invalidate("#search-form-input");
    }
}

const search_value = () => $("#search-form-input").val();
const search_link = query => `/search?category=quizzes&page=1&query=${query}`
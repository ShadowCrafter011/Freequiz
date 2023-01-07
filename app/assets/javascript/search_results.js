$(document).on("click", ".tab-control", function() {
    $(".tab").each((_, tab) => {
        tab.style.display = "none";
    });

    $(".tab-control").each((_, tab) => {
        $(tab).removeClass("active");
    });

    $(this).addClass("active");

    let show_id = $(this).attr("id") == "quizzes-tab" ? "#quiz-results" : "#user-results";
    $(show_id).css("display", "block");
});
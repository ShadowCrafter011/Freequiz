function filter_title() {
    console.log("filter")
}

var last_filter = "newest";
function sort() {
    let sort_option = $("#sort-selection").val();
    if (sort_option == last_filter) return;

    last_filter = sort_option;

    let quiz_container = $(".quiz-container");
    let quizzes = quiz_container.children();
    
    let reverse = false;
    let attribute = "created";

    switch (sort_option) {
        case "oldest":
        case "newest":
            reverse = sort_option == "oldest";
            attribute = "created";
            break;

        case "most_translations":
        case "least_translations":
            reverse = sort_option == "least_translations";
            attribute = "translations";
            break;
        
        default: break;
    }

    let to_sort = create_attribute_array(quizzes, attribute);
    to_sort.sort(compareFn);
    if (reverse) to_sort.reverse();
    
    let new_quiz_nodes = sorted_node_array(to_sort);
    quiz_container.empty();
    quiz_container.append(new_quiz_nodes);
}

function compareFn(a, b) {
    return Object.values(b)[0] - Object.values(a)[0];
}

function sorted_node_array(sorted_array) {
    output = [];
    for (let quiz_obj of sorted_array) {
        output.push($(`#${Object.keys(quiz_obj)[0]}`).clone(true));
    }
    return output;
}

function create_attribute_array(quizzes, attribute) {
    output = [];
    for (let quiz of quizzes) {
        quiz = $(quiz);
        let quiz_object = {};
        quiz_object[quiz.attr("id")] = quiz.data(attribute);
        output.push(quiz_object);
    }
    return output;
}
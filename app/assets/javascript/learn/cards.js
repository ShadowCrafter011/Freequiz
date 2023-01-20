let flip_card, word, translation, learned, unlearned, learning, done, available = [], current_card = null;
let quiz, quiz_data;
let scores_changed = [];

$(document).on("click", "#flip-card", function() { 
    $(this).toggleClass("flipped");
});

function load_elements() {
    flip_card = $("#flip-card");
    word = $("#word");
    translation = $("#translation");
    learned = $("#learned");
    unlearned = $("#unlearned");
    learning = $("#learning");
    done = $("#done");
}

async function setup(load=true) {
    load_elements();

    if (load) {
        await $.get({
            url: `/api/quiz/${quiz_id}/data`,
            headers: {
                "Access-token": access_token
            },
            success: function(data) {
                quiz = data.quiz_data;
                quiz_data  = quiz.data;
            },
            error: () => Turbo.visit("/")
        });
    }

    available = [];
    current_card = null;

    for (var x = 0; x < quiz_data.length; x++) {
        if (quiz_data[x].score.cards == 0) available.push(x);
    }

    update_data();

    current_card = await select_card();
    set_card(current_card);

    let interval = setInterval(save_score, 1000);
    $(document).on("turbo:visit", () => clearInterval(interval));
}

function save_score() {
    if (scores_changed.length == 0) return;

    let data = { score: {} };
    for (let translation_index of scores_changed) {
        let translation = quiz_data[translation_index];
        data.score[translation.hash] = translation.score;
    }
    
    $.ajax({
        type: "PATCH",
        url: `/api/quiz/${quiz.id}/score`,
        data: JSON.stringify(data),
        headers: {
            "Access-token": access_token
        },
        processData: false,
        contentType: "Application/json",
        error: err => console.error(err)
    });

    scores_changed = [];
}

async function reset_flip() {
    if (flip_card.hasClass("flipped")) {
        flip_card.toggleClass("flipped");
        await new Promise(resolve => setTimeout(resolve, 500));
    }
}

async function understood() {
    quiz_data[current_card].score.cards += 1;
    scores_changed.push(current_card);

    available.splice(available.indexOf(current_card), 1);
    quiz_data[current_card].score.cards = 1;

    current_card = await select_card();

    if (current_card == null) return;

    set_card(current_card);

    update_data();
}

async function learn_again() {
    if (available.length == 1) {
        return reset_flip();
    }

    var card = current_card
    available.splice(available.indexOf(current_card), 1);

    current_card = await select_card();
    set_card(current_card);

    available.push(card);
}

async function set_card(index) {
    word.text(quiz_data[index].w);
    await reset_flip();
    translation.text(quiz_data[index].t);
}

async function select_card() {
    if (available.length == 0) {
        word.text(done_text);
        await reset_flip();
        translation.text(done_text);
        available = [];
        update_data();

        learning.toggleClass("d-none");
        done.toggleClass("d-none");
        return;
    }

    num = Math.floor(Math.random() * available.length);
    return available[num];
}

function update_data() {
    unlearned.text(available.length);
    learned.text(quiz_data.length - available.length);
}

async function reset() {
    learning.toggleClass("d-none");
    done.toggleClass("d-none");

    for (let x in quiz_data) {
        quiz_data[x].score.cards = 0;
    }

    $.ajax({
        type: "PATCH",
        url: `/api/quiz/${quiz_id}/score/reset/cards`,
        headers:  {
            "Access-token": access_token
        }
    });

    setup(false);
}
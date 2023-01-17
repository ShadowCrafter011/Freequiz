let flip_card, word, translation, learned, unlearned, learning, done, available = [], current_card = null;

$(document).on("click", "#flip-card", function() { 
    $(this).toggleClass("flipped");
});

setup();
$(document).on("turbo:load", setup);

function load_elements() {
    flip_card = $("#flip-card");
    word = $("#word");
    translation = $("#translation");
    learned = $("#learned");
    unlearned = $("#unlearned");
    learning = $("#learning");
    done = $("#done");
}

function setup() {
    console.log("load")
    load_elements();

    available = [];
    current_card = null;

    for (var x = 0; x < quiz_data.length; x++) {
        if (quiz_data[x].score.cards == 0) available.push(x);
    }

    update_data();

    current_card = select_card();
    set_card(current_card);
}

async function reset_flip() {
    if (flip_card.hasClass("flipped")) {
        flip_card.toggleClass("flipped");
        await new Promise(resolve => setTimeout(resolve, 500));
    }
}

async function understood() {
    if (available.length == 1) {
        word.text(done_text);
        await reset_flip();
        translation.text(done_text);
        available = [];
        update_data();

        learning.toggleClass("d-none");
        done.toggleClass("d-none");
        return;
    }

    available.splice(available.indexOf(current_card), 1);
    quiz_data[current_card].score.cards = 1;

    current_card = select_card();
    set_card(current_card);

    update_data();
}

function learn_again() {
    if (available.length == 1) {
        return reset_flip();
    }

    var card = current_card
    available.splice(available.indexOf(current_card), 1);

    current_card = select_card();
    set_card(current_card);

    available.push(card);
}

async function set_card(index) {
    word.text(quiz_data[index]["w"]);
    await reset_flip();
    translation.text(quiz_data[index]["t"]);
}

function select_card() {
    num = Math.floor(Math.random() * available.length);
    return available[num];
}

function update_data() {
    unlearned.text(available.length);
    learned.text(quiz_data.length - available.length);
}

function reset() {
    learning.toggleClass("d-none");
    done.toggleClass("d-none");

    for (var i = 0; i < quiz_data.length; i++) {
        quiz_data[i].score.cards = 0;
    }
    setup();
}
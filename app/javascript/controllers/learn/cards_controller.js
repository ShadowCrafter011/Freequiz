import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="learn--cards"
export default class extends Controller {
    static targets = [
        "accessToken",
        "quizID",
        "doneText",
        "flipCard",
        "word",
        "translation",
        "learned",
        "learning",
        "unlearned",
        "done",
        "progress",
    ];

    connect() {
        let element = $(this.element);

        this.access_token = element.data("access-token");
        this.quiz_id = element.data("quiz-uuid");
        this.done_text = element.data("done-text");

        this.flip_card = $(this.flipCardTarget);
        this.word = $(this.wordTarget);
        this.translation = $(this.translationTarget);
        this.learned = $(this.learnedTarget);
        this.unlearned = $(this.unlearnedTarget);
        this.learning = $(this.learningTarget);
        this.done = $(this.doneTarget);

        this.available = [];
        this.current_card = null;

        this.quiz;
        this.quiz_data;

        this.setup();
    }

    flip() {
        this.flip_card.toggleClass("flipped");
    }

    async setup(load = true) {
        if (load) {
            await $.get({
                url: `/api/quiz/${this.quiz_id}/data`,
                headers: {
                    Authorization: this.access_token,
                },
                success: (data) => {
                    this.quiz = data.quiz_data;
                    this.quiz_data = this.quiz.data;
                },
                error: () => Turbo.visit("/"),
            });
        }

        this.available = [];
        this.current_card = null;

        for (var x = 0; x < this.quiz_data.length; x++) {
            if (this.quiz_data[x].score.cards == 0) this.available.push(x);
        }

        this.update_data();

        this.current_card = await this.select_card();
        this.set_card(this.current_card);
    }

    async reset_flip() {
        if (this.flip_card.hasClass("flipped")) {
            this.flip_card.toggleClass("flipped");
            await new Promise((resolve) => setTimeout(resolve, 500));
        }
    }

    async understood() {
        this.quiz_data[this.current_card].score.cards = 1;
        let score_id = this.quiz_data[this.current_card].score_id;

        this.available.splice(this.available.indexOf(this.current_card), 1);

        $.ajax({
            method: "PATCH",
            url: `/api/quiz/${this.quiz_id}/score/${score_id}/cards`,
            headers: {
                Authorization: this.access_token,
            },
            data: {
                score: 1,
            },
            error: (e) => console.error(e),
        });

        this.current_card = await this.select_card();

        if (this.current_card == null) return;

        this.set_card(this.current_card);

        this.update_data();
    }

    async learn_again() {
        if (this.available.length == 1) {
            return this.reset_flip();
        }

        var card = this.current_card;
        this.available.splice(this.available.indexOf(this.current_card), 1);

        this.current_card = await this.select_card();
        this.set_card(this.current_card);

        this.available.push(card);
    }

    async set_card(index) {
        if (index == null) return;
        this.word.text(this.quiz_data[index].word);
        await this.reset_flip();
        this.translation.text(this.quiz_data[index].translation);
    }

    async select_card() {
        if (this.available.length == 0) {
            this.word.text(this.done_text);
            await this.reset_flip();
            this.translation.text(this.done_text);
            this.available = [];
            this.update_data();

            this.learning.toggleClass("hidden");
            this.done.toggleClass("hidden");
            return;
        }

        let num = Math.floor(Math.random() * this.available.length);
        return this.available[num];
    }

    update_data() {
        this.unlearned.text(this.available.length);
        let left = this.quiz_data.length - this.available.length;
        let percent = left / this.quiz_data.length;
        this.learned.text(left);
        $(this.progressTarget).css("width", percent * 100 + "%");
    }

    async reset() {
        this.learning.toggleClass("hidden");
        this.done.toggleClass("hidden");

        for (let x in this.quiz_data) {
            this.quiz_data[x].score.cards = 0;
        }

        $.ajax({
            type: "PATCH",
            url: `/api/quiz/${this.quiz_id}/score/reset/cards`,
            headers: {
                Authorization: this.access_token,
            },
        });

        this.setup(false);
    }
}

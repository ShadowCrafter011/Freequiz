export class MultipleChoice {
    static targets = ["button", "text"];

    constructor(quiz, answer_fn) {
        this.quiz = quiz;
        this.answer_fn = answer_fn;
        this.answered = false;

        MultipleChoice.targets.forEach((t) => {
            this[`${t}Target`] = $(
                `[data-learn--multiple-choice-target*="${t}"]`,
            );
        });

        this.buttonTarget.click(this.check.bind(this));
    }

    disconnect() {
        clearTimeout(this.timeout);
    }

    check(e) {
        if (this.answered) return;
        this.answered = true;

        let correct = this.quiz.check($(e.currentTarget).text(), this.answer);
        this.timeout = setTimeout(
            () => {
                this.answer_fn(correct);
                this.answered = false;
            },
            correct ? 1000 : 2000,
        );

        if (correct) {
            $(e.currentTarget).addClass("text-green-600");
        } else {
            $(e.currentTarget).addClass("text-red-600");
            $(
                this.buttonTarget
                    .toArray()
                    .find((b) => $(b).text() == this.answer),
            ).addClass("text-green-600");
        }
    }

    show_translation(translation, answer, other) {
        this.answer = answer;
        this.buttonTarget.removeClass("hidden text-green-600 text-red-600");

        this.textTarget.text(translation);
        this.buttonTarget.sort(() => Math.random() - 0.5);
        $(this.buttonTarget[0]).text(answer);

        other.sort(() => Math.random() - 0.5);
        for (let x = 0; x < 3; x++) {
            if (x >= other.length) {
                $(this.buttonTarget[x + 1]).addClass("hidden");
            } else {
                $(this.buttonTarget[x + 1]).text(other[x]);
            }
        }
    }
}

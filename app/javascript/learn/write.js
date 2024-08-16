export class LearnWrite {
    static targets = [
        "translateText",
        "word",
        "input",
        "checkButton",
        "border",
        "submit",
        "done",
        "continueButton",
        "wasRightButton",
        "wasWrongButton",
        "enableOnNewWord",
        "disableOnNewWord",
    ];

    constructor(parent, quiz) {
        this.$parent = $(parent);
        this.quiz = quiz;

        LearnWrite.targets.forEach((target) => {
            this[`${target}Target`] = this.$parent.find(
                `[data-learn--write-target*="${target}"]`,
            );
        });
    }

    show_translation(translation, limit = 1, mode = "write") {
        this.translation = translation;
        if (translation.score[mode] >= limit) {
            this.set_data(translation.word, this.$parent.data("translate-to"));
        } else {
            this.set_data(
                translation.translation,
                this.$parent.data("translate-from"),
            );
        }
    }

    set_data(word, translate_text) {
        this.inputTarget.val("");
        $(this.checkButtonTarget)
            .removeClass("bg-red-600")
            .addClass("bg-teal-700");
        $(this.translateTextTarget).text(translate_text);
        $(this.wordTarget)
            .removeClass("text-green-600 text-red-600")
            .text(word);
        $(this.borderTarget)
            .removeClass("border-red-600")
            .addClass("border-teal-700");
    }

    done() {
        $(this.submitTarget).addClass("hidden");
        $(this.doneTarget).removeClass("hidden");
    }

    continue() {
        $(this.enableOnNewWordTarget).removeClass("hidden");
        $(this.disableOnNewWordTarget)
            .addClass("hidden")
            .removeClass("text-red-600 text-green-600");
        $(this.inputTarget).removeClass(
            "caret-transparent text-red-600 text-green-600",
        );
        $(this.inputTarget).focus();
    }

    reset() {
        this.quiz.reset_score();
        $(this.submitTarget).removeClass("hidden");
        $(this.doneTarget).addClass("hidden");
    }

    check(limit = 1, mode = "write") {
        let submitted = $(this.inputTarget).val();
        let correct =
            this.translation.score[mode] >= limit
                ? this.translation.translation
                : this.translation.word;
        let other =
            this.translation.score[mode] >= limit
                ? this.translation.word
                : this.translation.translation;

        let color, icon;

        let answered_correctly = this.quiz.check(submitted, correct);
        if (answered_correctly) {
            color = "text-green-600";
            icon = "✔";
            $(this.wordTarget).addClass(color).text(`${other} = ${correct}`);
            $(this.wasWrongButtonTarget).removeClass("hidden");

            this.quiz.increment_score();
        } else {
            color = "text-red-600";
            icon = "❌";
            $(this.wordTarget).addClass(color).text(`${other} = ${correct}`);
            $(this.borderTarget)
                .removeClass("border-teal-700")
                .addClass("border-red-600");
            $(this.wasRightButtonTarget).removeClass("hidden");
        }

        $(this.enableOnNewWordTarget).addClass("hidden");
        $(this.inputTarget)
            .addClass(color)
            .addClass("caret-transparent")
            .val(`${submitted} ${icon}`);
        $(this.continueButtonTarget).removeClass("hidden");

        return answered_correctly;
    }
}

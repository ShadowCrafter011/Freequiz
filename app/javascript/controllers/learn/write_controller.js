import { Controller } from "@hotwired/stimulus";
import { Quiz } from "quiz";
import { RadialProgressBar } from "progress_bars/radial";

// Connects to data-controller="learn--write"
export default class extends Controller {
    static targets = [
        "title",
        "radialProgressBar",
        "translateText",
        "word",
        "input",
        "checkButton",
        "border",
        "submit",
        "done",
        "failedToSave",
        "answeredWord",
        "continueButton",
        "wasRightButton",
        "wasWrongButton",
        "enableOnNewWord",
        "disableOnNewWord",
    ];

    async connect() {
        let element = $(this.element);
        this.quiz = new Quiz(
            "write",
            element.data("quiz-uuid"),
            element.data("access-token"),
            this.failedToSaveTarget,
        );

        await this.quiz.load();

        $(this.titleTarget).text(this.quiz.title);

        this.radial_progress_bar = new RadialProgressBar(
            this.radialProgressBarTarget,
            $(this.radialProgressBarTarget).data("neutral-color"),
        );

        this.waiting_for_continue = false;
        this.document = $(document);
        this.document.on("keydown", () => {
            if (this.waiting_for_continue) {
                this.continue();
                this.waiting_for_continue = false;
            }
        });

        this.update_progress_bar();

        this.show_random_translation();
    }

    disconnect() {
        this.quiz.upload_if_failed_to_save();
        this.document.off("keydown");
    }

    reset() {
        this.quiz.reset_score();
        this.update_progress_bar();
        this.show_random_translation();
        $(this.submitTarget).removeClass("hidden");
        $(this.doneTarget).addClass("hidden");
    }

    check() {
        let submitted = $(this.inputTarget).val();
        let correct =
            this.translation.score.write >= 1
                ? this.translation.translation
                : this.translation.word;
        let other =
            this.translation.score.write >= 1
                ? this.translation.word
                : this.translation.translation;

        let color, icon;

        if (this.quiz.check(submitted, correct)) {
            color = "text-green-600";
            icon = "✔";
            $(this.wordTarget).addClass(color).text(`${other} = ${correct}`);
            $(this.checkButtonTarget).text($(this.element).data("correct"));
            $(this.wasWrongButtonTarget).removeClass("hidden");

            this.quiz.increment_score();

            this.update_progress_bar();
        } else {
            color = "text-red-600";
            icon = "❌";
            $(this.wordTarget).addClass(color).text(`${other} = ${correct}`);
            $(this.borderTarget)
                .removeClass("border-teal-700")
                .addClass("border-red-600");
            $(this.wasRightButtonTarget).removeClass("hidden");
        }

        $(this.enableOnNewWordTargets).addClass("hidden");
        $(this.answeredWordTarget)
            .removeClass("hidden")
            .addClass(color)
            .text(`${submitted} ${icon}`);
        $(this.continueButtonTarget).removeClass("hidden");

        setTimeout(() => (this.waiting_for_continue = true));
    }

    continue() {
        $(this.enableOnNewWordTargets).removeClass("hidden");
        $(this.disableOnNewWordTargets)
            .addClass("hidden")
            .removeClass("text-red-600 text-green-600");
        console.log(this.disableOnNewWordTargets);
        this.update_progress_bar();
        this.show_random_translation();
        $(this.inputTarget).focus();
    }

    was_right() {
        this.quiz.increment_score();
        this.continue();
    }

    was_wrong() {
        this.quiz.decrement_score();
        this.continue();
    }

    show_random_translation() {
        this.translation = this.quiz.random_translation(
            (t) => t.score.write < 2,
        );

        if (!this.translation) {
            $(this.submitTarget).addClass("hidden");
            $(this.doneTarget).removeClass("hidden");
            return;
        }

        if (this.translation.score.write >= 1) {
            this.set_data(
                this.translation.word,
                $(this.element).data("translate-to"),
            );
        } else {
            this.set_data(
                this.translation.translation,
                $(this.element).data("translate-from"),
            );
        }
    }

    set_data(word, translate_text) {
        $(this.inputTarget).val("");
        $(this.checkButtonTarget)
            .removeClass("bg-red-600")
            .addClass("bg-teal-700")
            .text($(this.element).data("check"));
        $(this.translateTextTarget).text(translate_text);
        $(this.wordTarget)
            .removeClass("text-green-600 text-red-600")
            .text(word);
        $(this.borderTarget)
            .removeClass("border-red-600")
            .addClass("border-teal-700");
    }

    update_progress_bar() {
        let grouped = this.quiz.group_by_score();
        let total = this.quiz.translations_count;

        let data = [];
        let done = 0;

        if (2 in grouped) {
            done = grouped[2].length / total;
            data.push({
                coverage: done,
                fill_color: "fill-green-800 dark:fill-teal-800",
            });
        }
        if (1 in grouped) {
            data.push({
                coverage: grouped[1].length / total,
                fill_color: "fill-green-500 dark:fill-green-600",
            });
        }

        this.radial_progress_bar.set_data(data);
        this.radial_progress_bar.set_text(Math.floor(done * 100) + "%");
    }
}

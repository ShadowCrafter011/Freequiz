import { Controller } from "@hotwired/stimulus";
import { Quiz } from "quiz";
import { MultipleChoice } from "learn/multiple_choice";

// Connects to data-controller="learn--multiple-choice"
export default class extends Controller {
    static targets = ["failedToSave", "progressBar", "input", "done"];

    async connect() {
        this.$element = $(this.element);
        this.quiz = new Quiz(
            "multi",
            this.$element.data("quiz-uuid"),
            this.$element.data("access-token"),
            this.failedToSaveTarget,
        );

        await this.quiz.load();

        this.controller = new MultipleChoice(
            this.quiz,
            this.answered.bind(this),
        );
        this.update_progress_bar();
        this.show_random_translation();
    }

    disconnect() {
        this.controller.disconnect();
    }

    async reset() {
        await this.quiz.reset_score();
        $(this.inputTarget).removeClass("hidden");
        $(this.doneTarget).addClass("hidden");
        this.show_random_translation();
        this.update_progress_bar();
    }

    show_random_translation() {
        this.translation = this.quiz.random_translation_with(0);

        if (!this.translation) {
            $(this.inputTarget).addClass("hidden");
            $(this.doneTarget).removeClass("hidden");

            return;
        }

        let other = this.quiz.translations.filter(
            (t) => t.id != this.translation.id,
        );

        this.controller.show_translation(
            this.translation.word,
            this.translation.translation,
            other.map((t) => t.translation),
        );
    }

    answered(correct) {
        if (correct) {
            this.quiz.increment_score();
            this.update_progress_bar();
        }
        this.show_random_translation();
    }

    update_progress_bar() {
        $(this.progressBarTarget).css(
            "width",
            (this.quiz.translations.filter((t) => t.score.multi == 1).length /
                this.quiz.translations.length) *
                100 +
                "%",
        );
    }
}
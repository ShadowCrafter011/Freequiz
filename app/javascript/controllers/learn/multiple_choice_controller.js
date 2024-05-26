import { Controller } from "@hotwired/stimulus";
import { Quiz } from "quiz";
import { MultipleChoice } from "learn/multiple_choice";

// Connects to data-controller="learn--multiple-choice"
export default class extends Controller {
    static targets = ["failedToSave", "progressBar", "input", "done"];

    async connect() {
        this.$element = $(this.element);
        this.amount = this.$element.data("amount");
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
        this.translation = this.quiz.random_translation(
            (t) => t.score.multi < this.amount,
        );

        if (!this.translation) {
            $(this.inputTarget).addClass("hidden");
            $(this.doneTarget).removeClass("hidden");

            return;
        }

        let other = this.quiz.translations.filter(
            (t) => t.id != this.translation.id,
        );

        let word, trans, other_array;
        if (this.translation.score.multi == 0 && this.amount > 1) {
            word = this.translation.translation;
            trans = this.translation.word;
            other_array = other.map((t) => t.word);
        } else {
            word = this.translation.word;
            trans = this.translation.translation;
            other_array = other.map((t) => t.translation);
        }

        this.controller.show_translation(word, trans, other_array);
    }

    answered(correct) {
        if (correct) {
            this.quiz.increment_score();
            this.update_progress_bar();
        }
        this.show_random_translation();
    }

    update_progress_bar() {
        let total = 0;
        this.quiz.translations.forEach(
            (t) => (total += Math.min(t.score.multi, this.amount)),
        );

        $(this.progressBarTarget).css(
            "width",
            (total / this.quiz.translations.length / this.amount) * 100 + "%",
        );
    }
}

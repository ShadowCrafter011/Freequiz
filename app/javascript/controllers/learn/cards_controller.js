import { Controller } from "@hotwired/stimulus";
import { Quiz } from "quiz";

// Connects to data-controller="learn--cards"
export default class extends Controller {
    static targets = [
        "flipCard",
        "failedToSave",
        "word",
        "wordLanguage",
        "translation",
        "translationLanguage",
        "learned",
        "unlearned",
        "progressBar",
        "done",
        "learning",
        "percentage",
        "interval",
    ];

    async connect() {
        this.$element = $(this.element);
        this.amount = this.$element.data("amount");
        this.round_amount = this.$element.data("round-amount");
        this.this_round = 0;

        this.quiz = new Quiz(
            "cards",
            this.$element.data("quiz-uuid"),
            this.$element.data("access-token"),
            this.failedToSaveTarget,
        );

        await this.quiz.load();

        this.queue_translations();

        this.show_translation();
        this.update_progress();
    }

    queue_translations() {
        let available_translations = this.quiz.translations.filter(
            (t) => t.score.cards < this.amount,
        );
        available_translations.sort(() => Math.random() - 0.5);
        if (!this.next) this.next = [];
        this.next = this.next.concat(
            available_translations.slice(
                0,
                this.round_amount - this.next.length,
            ),
        );
        this.next = [...new Set(this.next)];
    }

    async show_translation() {
        this.next.sort(() => Math.random() - 0.5);
        this.translation = this.next.shift();
        this.quiz.selected_translation(this.translation);

        if (
            this.quiz.total_score() >=
            this.quiz.translations.length * this.amount
        ) {
            $(this.learningTarget).addClass("hidden");
            $(this.doneTarget).removeClass("hidden");

            return;
        }

        if (!this.translation) {
            this.queue_translations();
            this.show_translation();
            return;
        }

        let translation_text, translation_language;
        if (this.translation.score.cards == 0 && this.amount > 1) {
            $(this.wordTarget).text(this.translation.translation);
            $(this.wordLanguageTarget).text(this.quiz.translation_language);

            translation_text = this.translation.word;
            translation_language = this.quiz.word_language;
        } else {
            $(this.wordTarget).text(this.translation.word);
            $(this.wordLanguageTarget).text(this.quiz.word_language);

            translation_text = this.translation.translation;
            translation_language = this.quiz.translation_language;
        }

        if ($(this.flipCardTarget).hasClass("flipped")) {
            $(this.flipCardTarget).removeClass("flipped");
            await new Promise((resolve) => setTimeout(resolve, 200));
        }

        $(this.translationTarget).text(translation_text);
        $(this.translationLanguageTarget).text(translation_language);
    }

    update_progress() {
        let done = this.quiz.translations.filter(
            (t) => t.score.cards >= this.amount,
        ).length;
        let to_do = this.quiz.translations.length - done;

        $(this.learnedTarget).text(done);
        $(this.unlearnedTarget).text(to_do);

        let total = 0;
        this.quiz.translations.forEach(
            (t) => (total += Math.min(t.score.cards, this.amount)),
        );
        let percent_done =
            (total / this.quiz.translations.length / this.amount) * 100;
        $(this.progressBarTarget).css("width", percent_done + "%");
        $(this.percentageTarget).text(Math.floor(percent_done));
    }

    flip() {
        $(this.flipCardTarget).toggleClass("flipped");
    }

    continue() {
        this.this_round = 0;
        this.toggle_interval();
        this.queue_translations();
        this.show_translation();
        this.update_progress();
    }

    toggle_interval() {
        $(this.intervalTargets).toggleClass("hidden");
    }

    learn_again() {
        this.next.push(this.translation);
        if (this.increment_round()) return;
        this.show_translation();
    }

    understood() {
        this.quiz.increment_score();
        this.update_progress();
        if (this.increment_round()) return;
        this.show_translation();
    }

    increment_round() {
        this.this_round++;

        let translations_left = this.quiz.translations.filter(
            (t) => t.score.cards < this.amount,
        ).length;

        if (this.this_round >= this.round_amount && translations_left > 0) {
            this.toggle_interval();
            return true;
        }
        return false;
    }

    reset() {
        this.quiz.reset_score();
        this.this_round = 0;
        this.queue_translations();
        this.show_translation();
        this.update_progress();
        $(this.doneTarget).addClass("hidden");
        $(this.learningTarget).removeClass("hidden");
    }
}

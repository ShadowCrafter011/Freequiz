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
    ];

    async connect() {
        this.$element = $(this.element);
        this.amount = this.$element.data("amount");

        this.quiz = new Quiz(
            "cards",
            this.$element.data("quiz-uuid"),
            this.$element.data("access-token"),
            this.failedToSaveTarget,
        );

        await this.quiz.load();

        this.show_translation();
        this.update_progress();
    }

    async show_translation() {
        let translation = this.quiz.random_translation(
            (t) => t.score.cards < this.amount,
        );

        if (!translation) {
            $(this.learningTarget).addClass("hidden");
            $(this.doneTarget).removeClass("hidden");

            return;
        }

        let translation_text, translation_language;
        if (translation.score.cards == 0 && this.amount > 1) {
            $(this.wordTarget).text(translation.translation);
            $(this.wordLanguageTarget).text(this.quiz.translation_language);

            translation_text = translation.word;
            translation_language = this.quiz.word_language;
        } else {
            $(this.wordTarget).text(translation.word);
            $(this.wordLanguageTarget).text(this.quiz.word_language);

            translation_text = translation.translation;
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
        $(this.progressBarTarget).css(
            "width",
            (total / this.quiz.translations.length / this.amount) * 100 + "%",
        );
    }

    flip() {
        $(this.flipCardTarget).toggleClass("flipped");
    }

    learn_again() {
        this.show_translation();
    }

    understood() {
        this.quiz.increment_score();
        this.show_translation();
        this.update_progress();
    }

    reset() {
        this.quiz.reset_score();
        this.show_translation();
        this.update_progress();
        $(this.doneTarget).addClass("hidden");
        $(this.learningTarget).removeClass("hidden");
    }
}

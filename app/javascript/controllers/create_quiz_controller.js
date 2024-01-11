import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="create-quiz"
export default class extends Controller {
    static targets = ["translations", "template"];

    connect() {
        $(document).on("keydown", (e) => {
            if (e.key == "Enter") this.add_translation(e);
        });
    }

    add_translation(event) {
        event.preventDefault();
        let translations = $(this.translationsTarget);
        let template = $(this.templateTarget);
        let translation_amount = translations.children().length;
        let new_translation = translations.append(
            template.children().first().clone(true),
        );
        let word = new_translation.find(
            "[data-test-id='quiz-translation-template-word']",
        );
        let translation = new_translation.find(
            "[data-test-id='quiz-translation-template-translation']",
        );
        console.log(word);
        word.attr(
            "data-test-id",
            `quiz-translation-${translation_amount}-word`,
        );
        translation.attr(
            "data-test-id",
            `quiz-translation-${translation_amount}-translation`,
        );
        window.scrollTo(0, document.body.scrollHeight);
    }
}

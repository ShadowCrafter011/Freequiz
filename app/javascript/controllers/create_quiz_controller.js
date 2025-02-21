import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="create-quiz"
export default class extends Controller {
    static targets = [
        "translations",
        "importQuiz",
        "importText",
        "importTextField",
    ];

    connect() {
        this.document = $(document);
        this.document.on("keydown", (e) => {
            if (e.key == "Enter") this.add_translation(e);
            if (e.key == "Tab") {
                let inputs = $(this.translationsTargets).find(
                    'input[data-create-quiz-target="input"]',
                );
                let id = `#${$(e.target).attr("id")}`;
                let index = inputs.index($(id));
                if (index + 2 >= inputs.length) this.append_translation();
            }
        });

        this.template = $(this.translationsTarget)
            .children()
            .first()
            .clone(true);
        this.template
            .find('[data-create-quiz-target="strikeThrough"]')
            .addClass("hidden");

        let destroy = this.template.find('[data-create-quiz-target="destroy"]');
        destroy.val("0");
        let inputs = this.template.find('[data-create-quiz-target="input"]');
        inputs.val("");

        this.max_id = -1;
        let word_inputs = $("input[name*='[word]']");
        for (let input of word_inputs) {
            let id = parseInt($(input).attr("id").match(/\d+/)[0]);
            if (id > this.max_id) this.max_id = id;
        }
    }

    disconnect() {
        this.document.off("keydown");
    }

    add_translation(event) {
        event.preventDefault();
        this.append_translation();
    }

    append_translation() {
        $(this.translationsTarget).append(this.get_new_template());
        window.scrollTo(0, document.body.scrollHeight);
    }

    get_new_template() {
        let template = this.template.clone(0);

        let all_fields = template.find(
            '[data-create-quiz-target="destroy"], [data-create-quiz-target="input"]',
        );

        this.replace_attrs(all_fields, ["name", "id"]);

        return template;
    }

    replace_attrs(collection, attrs) {
        this.max_id++;

        for (let attr of attrs) {
            for (let node of collection) {
                $(node).attr(
                    attr,
                    $(node).attr(attr).replace(/(\d+)/gm, this.max_id),
                );
            }
        }
    }

    import_quiz_click(e) {
        let message = $(this.importQuizTarget).data("confirm-message");

        if (!confirm(message)) {
            e.preventDefault();
        }
    }

    import_quiz(e) {
        let fr = new FileReader();

        fr.onload = () => {
            this.load_quiz_text(fr.result);
        };

        fr.readAsText(e.target.files[0]);
    }

    show_import_text() {
        $(this.importTextTarget).removeClass("hidden");
    }

    import_text() {
        let message = $(this.importQuizTarget).data("confirm-message");

        if (!confirm(message)) {
            return;
        }

        this.load_quiz_text($(this.importTextFieldTarget).val());

        $(this.importTextTarget).addClass("hidden");
    }

    load_quiz_text(text) {
        let error_msg = $(this.importQuizTarget).data("error-message");

        text = text.trim();

        if (!text) {
            return alert(error_msg);
        }

        let lines = text.split("\n");

        lines = lines.filter((l) => l.trim());

        if (lines.length == 0) {
            return alert(error_msg);
        }

        let separators = ["\t", ",", ";", ":", "|", "¦"];
        let found_separator = false;
        let separator = null;

        for (let sep of separators) {
            let separator_valid = true;
            for (let line of lines) {
                if (line.split(sep).length != 2) {
                    separator_valid = false;
                }
            }

            if (separator_valid) {
                found_separator = true;
                separator = sep;
                break;
            }
        }

        if (!found_separator) {
            return alert(error_msg);
        }

        let translation_lines = lines.map((l) => l.trim().split(separator));

        let translations = $(this.translationsTarget);

        for (let translation_line of translation_lines) {
            let translation = this.get_new_template();
            let inputs = translation.find('[data-create-quiz-target="input"]');
            $(inputs[0]).val(translation_line[0]);
            $(inputs[1]).val(translation_line[1]);
            translations.append(translation);
        }

        // Remove empty translations
        translations.children().each(function () {
            let inputs = $(this).find('[data-create-quiz-target="input"]');

            let all_blank = true;
            inputs.each(function () {
                if ($(this).val()) all_blank = false;
            });

            if (all_blank) {
                $(this).remove();
            }
        });
    }
}

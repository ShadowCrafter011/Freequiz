import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="create-quiz"
export default class extends Controller {
    static targets = ["translations"];

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
    }

    disconnect() {
        this.document.off("keydown");
    }

    add_translation(event) {
        event.preventDefault();
        this.append_translation();
    }

    append_translation() {
        let template = $(this.translationsTarget)
            .children()
            .first()
            .clone(true);
        template
            .find('[data-create-quiz-target="strikeThrough"]')
            .addClass("hidden");

        let destroy = template.find('[data-create-quiz-target="destroy"]');
        destroy.val("0");
        let inputs = template.find('[data-create-quiz-target="input"]');
        inputs.val("");

        let all = inputs.add(destroy);
        this.replace_attr(all, "name");
        this.replace_attr(all, "id");

        $(this.translationsTarget).append(template);
        window.scrollTo(0, document.body.scrollHeight);
    }

    replace_attr(collection, attr) {
        for (let node of collection) {
            $(node).attr(
                attr,
                $(node).attr(attr).replace(/(\d+)/gm, new Date().getTime()),
            );
        }
    }
}

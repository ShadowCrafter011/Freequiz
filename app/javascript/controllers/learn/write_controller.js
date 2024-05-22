import { Controller } from "@hotwired/stimulus";
import { Quiz } from "quiz";
import { RadialProgressBar } from "progress_bars/radial";
import { LearnWrite } from "learn/write";

// Connects to data-controller="learn--write"
export default class extends Controller {
    static targets = ["title", "radialProgressBar"];

    async connect() {
        let $element = $(this.element);
        this.$document = $(document);
        this.quiz = new Quiz(
            "write",
            $element.data("quiz-uuid"),
            $element.data("access-token"),
            this.failedToSaveTarget,
        );

        await this.quiz.load();

        this.controller = new LearnWrite(this.element, this.quiz);

        $(this.titleTarget).text(this.quiz.title);

        this.radial_progress_bar = new RadialProgressBar(
            this.radialProgressBarTarget,
            $(this.radialProgressBarTarget).data("neutral-color"),
        );

        this.update_progress_bar();

        this.show_random_translation();
    }

    add_continue_listener() {
        this.$document.on("keydown", () => {
            this.continue();
            this.$document.off("keydown");
        });
    }

    disconnect() {
        this.$document.off("keydown");
        this.quiz.upload_if_failed_to_save();
    }

    reset() {
        this.controller.reset();
        this.update_progress_bar();
        this.show_random_translation();
    }

    check() {
        this.controller.check();
        this.update_progress_bar();
        setTimeout(this.add_continue_listener.bind(this));
    }

    continue() {
        this.controller.continue();
        this.update_progress_bar();
        this.show_random_translation();
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
            this.controller.done();
            return;
        }

        this.controller.show_translation(this.translation);
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

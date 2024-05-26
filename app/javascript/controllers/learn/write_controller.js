import { Controller } from "@hotwired/stimulus";
import { Quiz } from "quiz";
import { RadialProgressBar } from "progress_bars/radial";
import { LearnWrite } from "learn/write";

// Connects to data-controller="learn--write"
export default class extends Controller {
    static targets = ["title", "radialProgressBar", "failedToSave"];

    async connect() {
        let $element = $(this.element);
        this.$document = $(document);
        this.amount = $element.data("amount");
        this.quiz = new Quiz(
            "write",
            $element.data("quiz-uuid"),
            $element.data("access-token"),
            this.failedToSaveTarget,
        );
        this.waiting_for_continue = false;

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
        this.waiting_for_continue = true;
        this.$document.on("keydown", () => {
            this.continue();
            this.waiting_for_continue = false;
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
        if (this.waiting_for_continue) return;
        this.controller.check();
        this.update_progress_bar();
        setTimeout(this.add_continue_listener.bind(this));
    }

    continue() {
        this.controller.continue();
        this.update_progress_bar();
        this.show_random_translation();
        this.$document.off("keydown");
        this.waiting_for_continue = false;
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
            (t) => t.score.write < this.amount,
        );

        if (!this.translation) {
            this.controller.done();
            return;
        }

        this.controller.show_translation(this.translation);
    }

    update_progress_bar() {
        let grouped = this.quiz.group_by_score();
        let total = this.quiz.translations_count * this.amount;

        let colors = [
            "fill-blue-500 dark:fill-blue-500",
            "fill-green-500 dark:fill-green-600",
            "fill-green-800 dark:fill-teal-800",
        ];

        colors = colors.slice(3 - this.amount);
        console.log(colors);

        let data = [];
        let done = 0;
        for (let x = 3; x > 0; x--) {
            if (x in grouped) {
                done += grouped[x].length * Math.min(x, this.amount);
                data.push({
                    coverage: grouped[x].length / this.quiz.translations_count,
                    fill_color: colors[Math.min(x, this.amount) - 1],
                });
            }
        }

        // for (let i = 0; i < data.length; i++) data[i].fill_color = colors[i];

        this.radial_progress_bar.set_data(data);
        this.radial_progress_bar.set_text(
            Math.floor((done / total) * 100) + "%",
        );
    }
}

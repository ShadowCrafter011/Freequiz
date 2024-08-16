import { Controller } from "@hotwired/stimulus";
import { Quiz } from "quiz";
import { LearnWrite } from "learn/write";
import { MultipleChoice } from "learn/multiple_choice";

// Connects to data-controller="learn--smart"
export default class extends Controller {
    static targets = [
        "multi",
        "write",
        "writeInput",
        "writeCheck",
        "failedToSave",
        "progressText",
        "progress1",
        "progress2",
        "progress3",
        "done",
        "multiButton",
        "interval",
        "intervalPercentage",
    ];

    async connect() {
        let $element = $(this.element);
        this.$document = $(document);
        this.round_amount = $element.data("round-amount");
        this.quiz = new Quiz(
            "smart",
            $element.data("quiz-uuid"),
            $element.data("access-token"),
            this.failedToSaveTarget,
        );

        this.$document.on("keydown", this.handle_keydown.bind(this));

        this.next = [];
        this.wrong = [];

        await this.quiz.load();

        this.write_controller = new LearnWrite(this.element, this.quiz);
        this.multi_controller = new MultipleChoice(
            this.quiz,
            this.answered.bind(this),
        );

        $(this.titleTarget).text(this.quiz.title);

        this.update_progress_bar();
        this.queue_translations();
        this.show_random_translation();
    }

    disconnect() {
        this.multi_controller.disconnect();
        this.$document.off("keydown");
    }

    handle_keydown(e) {
        if (e.ctrlKey) return;

        if (
            !$(this.multiTarget).hasClass("hidden") &&
            ["1", "2", "3", "4"].includes(e.key)
        ) {
            e.preventDefault();
            let buttons = this.multiButtonTargets.filter(
                (b) => !$(b).hasClass("hidden"),
            );
            let target = buttons[parseInt(e.key) - 1];
            if (target) this.multi_controller.check({ currentTarget: target });
        } else if (!$(this.writeCheckTarget).hasClass("hidden")) {
            e.preventDefault();
            this.write_controller.continue();
            this.continue();
        } else if (!$(this.intervalTarget).hasClass("hidden")) {
            e.preventDefault();
            this.continue();
        }
    }

    queue_translations() {
        this.next = this.next.concat(this.wrong);
        this.wrong = [];

        if (this.next.length < this.round_amount) {
            let available = this.quiz.translations.filter(
                (t) => t.score.smart < 3 && !this.next.includes(t),
            );
            available.sort(() => Math.random() - 0.5);
            this.next = this.next.concat(
                available.slice(
                    0,
                    Math.max(0, this.round_amount - this.next.length),
                ),
            );
        }

        this.next.sort(() => Math.random() - 0.5);
    }

    show_random_translation() {
        if (this.quiz.total_score() >= this.quiz.translations_count * 3) {
            $(this.doneTarget).removeClass("hidden");
            return;
        }

        this.translation = this.next.shift();

        if (!this.translation) {
            let total_score = 0;
            let grouped = this.quiz.group_by_score();
            for (let x = 1; x <= 3; x++) {
                if (!(x in grouped)) continue;

                total_score += grouped[x].length * x;
            }
            $(this.intervalPercentageTarget).text(
                Math.floor(
                    (total_score / (this.quiz.translations_count * 3)) * 100,
                ),
            );

            $(this.intervalTarget).removeClass("hidden");
            this.queue_translations();
            return;
        }

        this.quiz.selected_translation(this.translation);

        let other = this.quiz.translations
            .filter((t) => t != this.translation)
            .map((t) => t.translation)
            .slice(0, 3);

        switch (this.translation.score.smart) {
            case 0:
                $(this.multiTarget).removeClass("hidden");
                this.multi_controller.show_translation(
                    this.translation.word,
                    this.translation.translation,
                    other,
                );
                break;
            default:
                $(this.writeTarget).removeClass("hidden");
                this.write_controller.show_translation(
                    this.translation,
                    2,
                    "smart",
                );
                $(this.writeInputTarget).removeAttr("disabled");
                $(this.writeInputTarget).focus();
                break;
        }
    }

    continue() {
        $(this.writeTarget).addClass("hidden");
        $(this.multiTarget).addClass("hidden");
        $(this.intervalTarget).addClass("hidden");
        this.update_progress_bar();
        this.show_random_translation();
    }

    write_check() {
        this.$document.off("keydown");
        setTimeout(() =>
            this.$document.on("keydown", this.handle_keydown.bind(this)),
        );
        $(this.writeInputTarget).attr("disabled", "true");
        let correct = this.write_controller.check(2, "smart");
        if (!correct) this.wrong.push(this.translation);
        this.update_progress_bar();
    }

    write_continue() {
        this.write_controller.continue();
        this.continue();
    }

    write_was_right() {
        this.quiz.increment_score();
        this.write_controller.continue();
        this.continue();
    }

    write_was_wrong() {
        this.quiz.decrement_score();
        this.write_controller.continue();
        this.continue();
    }

    update_progress_bar() {
        let grouped = this.quiz.group_by_score();
        let total = this.quiz.translations_count * 3;
        let done_mul = 0;
        let done = 0;
        for (let x = 3; x > 0; x--) {
            if (!(x in grouped)) continue;
            done_mul += grouped[x].length * x;
            done += grouped[x].length;
            $(this[`progress${x}Target`]).css(
                "width",
                (done / this.quiz.translations_count) * 100 + "%",
            );
        }
        $(this.progressTextTarget).text(
            `${Math.floor((done_mul / total) * 100)}%`,
        );
    }

    answered(correct) {
        if (correct) {
            this.quiz.increment_score();
        } else {
            this.wrong.push(this.current_translation);
        }

        this.continue();
    }

    reset() {
        this.quiz.reset_score();
        $(this.doneTarget).addClass("hidden");
        this.queue_translations();
        this.show_random_translation();
        this.update_progress_bar();
        for (let x = 1; x <= 3; x++) {
            $(this[`progress${x}Target`]).css("width", "0%");
        }
    }
}

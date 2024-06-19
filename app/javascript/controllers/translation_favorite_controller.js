import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="translation-favorite"
export default class extends Controller {
    static targets = ["star"];

    connect() {
        this.$element = $(this.element);
        this.favorite = this.$element.data("favorite");
        this.score_id = this.$element.data("score-id");
        this.quiz_id = this.$element.data("quiz-id");
        this.access_token = this.$element.data("access-token");
        this.error = this.$element.data("error");
    }

    toggle() {
        $(this.starTargets).toggleClass("hidden");
        $.ajax({
            url: `/api/quiz/${this.quiz_id}/score/${this.score_id}/favorite`,
            method: "PATCH",
            headers: {
                Authorization: this.access_token,
            },
            data: {
                favorite: !this.favorite,
            },
            success: () => {
                this.favorite = !this.favorite;
            },
            error: () => {
                $(this.starTargets).toggleClass("hidden");
                alert(this.error);
            },
        });
    }
}

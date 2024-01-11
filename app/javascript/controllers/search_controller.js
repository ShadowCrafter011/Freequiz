import { Controller } from "@hotwired/stimulus";
import { invalidate_element } from "../util/invalidate";

// Connects to data-controller="search"
export default class extends Controller {
    static targets = ["query"];

    submit(e) {
        e.preventDefault();
        this.check();
    }

    check() {
        let query = $(this.queryTarget).val();
        if (query.length > 0) {
            Turbo.visit(`/search?category=quizzes&page=1&query=${query}`);
        } else {
            invalidate_element(this.queryTarget);
        }
    }
}

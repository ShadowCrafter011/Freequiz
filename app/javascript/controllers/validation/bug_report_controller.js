import { Controller } from "@hotwired/stimulus";
import { invalidate_element } from "../../util/invalidate";

// Connects to data-controller="validation--bug-report"
export default class extends Controller {
    static targets = ["url", "title", "body"];

    connect() {
        $(this.urlTarget).val(location.href);
    }

    check(e) {
        this.min_length(e, this.titleTarget, 1);
        this.min_length(e, this.bodyTarget, 10);
    }

    min_length(event, element, length) {
        let el = $(element);

        if (el.val().length < length) {
            event.preventDefault();
            invalidate_element(el);
        }
    }
}

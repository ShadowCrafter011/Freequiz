import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="delete-translation"
export default class extends Controller {
    static targets = ["field", "strikeThrough"];

    toggle() {
        $(this.fieldTarget).val($(this.fieldTarget).val() == "0" ? "1" : "0");
        $(this.strikeThroughTarget).toggleClass("hidden");
    }
}

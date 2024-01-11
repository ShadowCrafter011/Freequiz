import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="dirtyform"
export default class extends Controller {
    connect() {
        $(this.element).dirtyForms();
    }
}

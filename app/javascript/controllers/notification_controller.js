import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="notification"
export default class extends Controller {
    static targets = ["body"];

    connect() {
        let body = $(this.bodyTarget);
        if (body.children().length > 0) {
            bootstrap.Toast.getOrCreateInstance(this.element).show();
        }
    }
}

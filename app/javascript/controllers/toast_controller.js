import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="toast"
export default class extends Controller {
    connect() {
        bootstrap.Toast.getOrCreateInstance(this.element).show();
    }
}

import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="navbar-expand"
export default class extends Controller {
    static targets = ["menu"];

    toggle() {
        $(this.menuTarget).toggleClass("hidden");
    }
}

import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="dropdown"
export default class extends Controller {
    static targets = ["menu"];

    connect() {
        this.click_fn = this.handle_click.bind(this);
        document.addEventListener("click", this.click_fn);
    }

    disconnect() {
        document.removeEventListener("click", this.click_fn);
    }

    handle_click(e) {
        let menu = $(this.menuTarget);
        let target = $(e.target);
        if (
            !menu.hasClass("hidden") &&
            !target.parents().is(menu) &&
            !target.parents().is(this.element)
        ) {
            menu.addClass("hidden");
        }
    }

    toggle() {
        $(this.menuTarget).toggleClass("hidden");
    }
}

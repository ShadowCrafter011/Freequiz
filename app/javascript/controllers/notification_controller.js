import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="notification"
export default class extends Controller {
    static targets = ["progress"];

    connect() {
        if ($(this.element).data("show") == false) return;

        this.toggle();
        $(this.progressTarget).removeClass("-translate-x-1/2 scale-x-0");
        let regex = /duration-\[(\d+)ms\]/gm;
        let duration = regex.exec($(this.progressTarget).attr("class"))[1];
        this.timeout = setTimeout(this.toggle.bind(this), duration);
    }

    disconnect() {
        clearTimeout(this.timeout);
    }

    toggle() {
        $(this.element).toggleClass(
            "opacity-0 opacity-100 pointer-events-none pointer-events-auto",
        );
        clearTimeout(this.timeout);
    }

    update_progress() {
        let total = new Date().getTime() - this.start;
        $(this.progressTarget).css("width", total / 50 + "%");
    }
}

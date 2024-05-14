import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="popup"
export default class extends Controller {
    static targets = ["popup"];

    connect() {
        if (this.hasPopupTarget) {
            this.target = $(this.popupTarget);
        } else {
            this.target = $($(this.element).data("target"));
            this.close_button = this.target.find('[data-close="popup"]');
            this.close_button.click(this.hide.bind(this));
        }
    }

    disconnect() {
        this.close_button.off("click");
    }

    hide() {
        this.target.addClass("pointer-events-none opacity-0");
        this.target.removeClass("opacity-100");
    }

    show() {
        this.target.removeClass("pointer-events-none opacity-0");
        this.target.addClass("opacity-100");
    }
}

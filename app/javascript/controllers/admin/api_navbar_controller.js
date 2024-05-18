import { Controller } from "@hotwired/stimulus";
import "jquery-most-visible";

// Connects to data-controller="admin--api-navbar"
export default class extends Controller {
    static targets = ["link"];

    connect() {
        this.activate_links(location.hash);
        $(window).on("hashchange", (e) => {
            let split = e.originalEvent.newURL.split("#");
            let new_anchor = split[1];
            this.activate_links(`#${new_anchor}`);
        });
        this.document = $(document);
        this.document.on("scroll", this.handle_scroll.bind(this));
    }

    disconnect() {
        this.document.off("scroll");
    }

    handle_scroll() {
        let most_visible = $('[data-section="true"]').mostVisible();
        let most_visible_id = `#${most_visible.attr("id")}`;

        if (most_visible_id == "#undefined") return;

        if (most_visible_id != location.hash) {
            this.activate_links(most_visible_id);
            history.pushState(null, "", most_visible_id);
        }
    }

    activate_links(anchor) {
        let cls =
            "underline text-blue-800 hover:text-blue-800 dark:text-teal-600 dark:hover:text-teal-500";
        $(this.linkTargets).removeClass(cls);

        this.section_name = $(this.element).data("action-name");
        this.main_link = $(`[data-id='${this.section_name}']`);
        this.main_link.addClass(cls);

        if (anchor) {
            let anchor_no_hash = anchor.replace("#", "");
            this.sub_section = $(
                `[data-subsection="${this.section_name}.${anchor_no_hash}"]`,
            );
            this.sub_section.addClass(cls);
        }
    }
}

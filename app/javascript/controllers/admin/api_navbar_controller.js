import { Controller } from "@hotwired/stimulus";
import "jquery-most-visible";

// Connects to data-controller="admin--api-navbar"
export default class extends Controller {
  static targets = ["link", "actionName"];

  connect() {
    this.activate_and_set_scroll(location.hash);
    $(window).on("hashchange", e => {
      let new_anchor = e.originalEvent.newURL.split("#")[1];
      this.activate_and_set_scroll(`#${new_anchor}`);
    });
    var self = this;
    setTimeout(function() {
      $(document).on("scroll", () => self.handle_scroll(self));
    }, 100);
  }

  handle_scroll(self) {
    let most_visible = $(".section").mostVisible();
    self.activate_links(`#${most_visible.attr("id")}`);
    history.pushState(null, "", `#${most_visible.attr("id")}`);
  }

  activate_and_set_scroll(anchor) {
    this.activate_links(anchor);
    if (anchor && this.sub_section?.offset()?.top) {
      window.scrollTo(0, this.sub_section.offset().top);
    }
  }

  activate_links(anchor) {
    $(this.linkTargets).removeClass("active");

    this.section_name = $(this.actionNameTarget).text();
    this.main_link = $(`[data-id='${this.section_name}']`);
    this.main_link.addClass("active");

    if (anchor) {
      this.sub_section = $(anchor);
      this.sub_link = $(`div[data-section='${this.section_name}'] a[data-id='${anchor.replace("#", "")}']`);
      this.sub_link.addClass("active");
    }
  }
}

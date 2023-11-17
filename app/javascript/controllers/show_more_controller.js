import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="show-more"
export default class extends Controller {
  static targets = ["target", "showMore", "showLess"];

  connect() {
    this.target = $(this.targetTarget);
    this.show_more_btn = $(this.showMoreTarget);
    this.show_less_btn = $(this.showLessTarget);

    if (this.is_truncated(this.target)) {
      this.toggle_display([this.show_more_btn]);
    }
  }

  show_more() {
    this.target.removeClass("text-truncate");
    this.toggle_display([this.show_more_btn, this.show_less_btn]);
  }

  show_less() {
    this.target.addClass("text-truncate");
    this.toggle_display([this.show_more_btn, this.show_less_btn]);
  }

  is_truncated(element) {
    return (element.outerWidth() < element[0].scrollWidth);
  }

  toggle_display(elements) {
    elements.forEach(element => {
      element.toggleClass("d-block");
      element.toggleClass("d-none");
    });
  }
}

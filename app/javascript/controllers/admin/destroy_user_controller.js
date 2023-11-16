import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="admin--destroy-user"
export default class extends Controller {
  static targets = ["button"]

  click(e) {
    let button = $(e.target);
    if (button.data("confirmed")) return;

    button.data("confirmed", true);
    button.removeClass("btn-danger");
    button.addClass("btn-success");
    button.text("Confirmed");

    if (!this.all_confirmed()) {
      e.preventDefault();
    }
  }

  all_confirmed() {
    for (let btn of this.buttonTargets) {
      if (!$(btn).data("confirmed")) return false;
    }
    return true;
  }
}

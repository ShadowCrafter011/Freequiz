import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toast-button"
export default class extends Controller {
  connect() {
    let target = $(this.element).data("target");
    this.toast = bootstrap.Toast.getOrCreateInstance($(target));
  }

  show() {
    this.toast.show();
    console.log("show")
  }
}

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="translation"
export default class extends Controller {
  delete() {
    $(this.element).remove();
  }
}

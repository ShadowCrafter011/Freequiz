import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="prism"
export default class extends Controller {
  connect() {
    Prism.highlightElement(this.element);
  }
}

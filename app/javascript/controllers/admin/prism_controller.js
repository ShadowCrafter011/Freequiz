import { Controller } from "@hotwired/stimulus";
import "prism";
import "prism-json";

// Connects to data-controller="admin--prism"
export default class extends Controller {
    connect() {
        Prism.highlightElement(this.element);
    }
}

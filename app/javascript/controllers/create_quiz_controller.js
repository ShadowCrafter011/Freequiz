import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="create-quiz"
export default class extends Controller {
  static targets = ["translations", "template"];

  connect() {
    $(document).on("keydown", e => {
      if (e.key == "Enter") this.add_translation(e);
    });
  }

  add_translation(event) {
    event.preventDefault();
    let translations = $(this.translationsTarget);
    let template = $(this.templateTarget);
    translations.append(template.children().first().clone(true));
    window.scrollTo(0, document.body.scrollHeight);
  }
}

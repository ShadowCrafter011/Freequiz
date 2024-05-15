# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
# pin "bootstrap", to: "bootstrap.min.js", preload: true
# pin "@popperjs/core", to: "popper.js", preload: true
pin "jquery", to: "jquery.js"
pin "jquery-most-visible",
    to: "https://unpkg.com/most-visible@2.0.0/dist/most-visible.min.js"
pin "jaro-winkler", to: "https://ga.jspm.io/npm:jaro-winkler@0.2.8/index.js"
pin "dirtyforms", to: "jquery.dirtyforms.js"
pin "prism", to: "prism.js"
pin "prism-json", to: "prism-json.min.js"

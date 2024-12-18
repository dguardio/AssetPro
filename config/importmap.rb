# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/assets/javascripts/controllers", under: "controllers"

# Material Dashboard
pin_all_from "app/javascript/material-dashboard", under: "material-dashboard"

pin "bootstrap", to: "bootstrap.min.js"
pin "material-dashboard", to: "material-dashboard.js"
pin "@rails/actioncable", to: "actioncable.esm.js"
pin_all_from "app/javascript/channels", under: "channels"

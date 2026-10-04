project_name: "bre"

application: bre_portal {
  label: "BRE Operations Portal"

  # Production bundle compiled from frontend/
  file: "bundle.js"

  # For local development with hot-reload via webpack-dev-server, switch to:
  # url: "https://localhost:8080/bundle.js"

  entitlements: {
    local_storage: yes
    navigation: yes
    new_window: yes
    use_embeds: yes
    use_iframes: yes
    use_form_submit: yes
    core_api_methods: [
      "me",
      "all_dashboards",
      "dashboard"
    ]
  }
}

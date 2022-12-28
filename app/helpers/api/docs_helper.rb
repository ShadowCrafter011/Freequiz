module Api::DocsHelper
    def link(path_helper, link_name, anchor)
        link_to link_name, path_helper.call(anchor: anchor), class: "list-group-item list-group-item-action link", data: {turbo: false}
    end

    def activate_tab? tab
        action_name == tab.to_s ? "active" : ""
    end

    def show_tab? tab
        action_name == tab.to_s ? "show" : ""
    end

    def collapse_tab? tab
        action_name == tab.to_s ? "" : "data-bs-target=#users data-bs-toggle=collapse"
    end
end

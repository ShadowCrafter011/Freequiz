module Api::UserHelper
    def link(path_helper, link_name, anchor)
        link_to link_name, path_helper.call(anchor: anchor), class: "list-group-item list-group-item-action link"
    end
end

module Api::DocsHelper
    def nav_data
        {
            api_docs_path: {
                name: "Index",
                id: "index"
            },
            api_docs_authentication_path: {
                name: "Authentication",
                id: "authentication"
            },
            api_docs_general_errors_path: {
                name: "General errors",
                id: "general_errors"
            },
            api_docs_bugs_path: {
                name: "Bug reports",
                id: "bugs"
            },
            api_docs_languages_path: {
                name: "Languages",
                id: "languages"
            },
            api_docs_users_path: {
                name: "Users",
                id: "users",
                subsections: {
                    create: "Create",
                    exists: "Exists",
                    delete_token: "Delete token",
                    delete: "Delete",
                    login: "Login",
                    refresh: "Refresh",
                    data: "Data",
                    search: "Search",
                    user_quizzes: "Quizzes",
                    public: "Public",
                    update: "Update",
                    settings: "Settings"
                }
            },
            api_docs_quizzes_path: {
                name: "Quizzes",
                id: "quizzes",
                subsections: {
                    create: "Create",
                    delete_token: "Delete token",
                    delete: "Delete",
                    data: "Data",
                    search: "Search",
                    update: "Update",
                    favorites: "Favorites",
                    score: "Score",
                    reset_score: "Reset score"
                }
            }
        }
    end

    def render_navbar
        links = []
        nav_data.each_with_index do |data, index|
            path = data[0]
            other_data = data[1]
            name = other_data[:name]

            links.append "<div data-section='#{other_data[:id]}' class='section-parent'>"

            links.append(
                render(
                    partial: "api_navbar_link",
                    locals: {
                        indent: 0,
                        link_name: name,
                        index: index + 1,
                        path: method(path).call,
                        id: other_data[:id]
                    }
                )
            )

            if other_data.key? :subsections
                other_data[:subsections].each_with_index do |sub_data, sub_index|
                    links.append(
                        render(
                            partial: "api_navbar_link",
                            locals: {
                                indent: 1,
                                link_name: sub_data[1],
                                index: "#{index + 1}.#{sub_index + 1}",
                                path: method(path).call(anchor: sub_data[0]),
                                id: sub_data[0]
                            }
                        )
                    )
                end
            end

            links.append "</div>"
        end
        links.join("").html_safe
    end

    def link(path_helper, link_name, anchor)
        link_to link_name,
                path_helper.call(anchor:),
                class: "list-group-item list-group-item-action link"
    end

    def activate_tab?(tab)
        action_name == tab.to_s ? "active" : ""
    end

    def show_tab?(tab)
        action_name == tab.to_s ? "show" : ""
    end

    def collapse_tab?(tab)
        if action_name == tab.to_s
            ""
        else
            "data-bs-target=##{tab} data-bs-toggle=collapse"
        end
    end
end

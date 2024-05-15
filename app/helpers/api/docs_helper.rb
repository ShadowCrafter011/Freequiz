module Api::DocsHelper
    def nav_data
        {
            api_docs: {
                name: "Index",
                id: "index"
            },
            api_docs_authentication: {
                name: "Authentication",
                id: "authentication"
            },
            api_docs_general_errors: {
                name: "General errors",
                id: "general_errors"
            },
            api_docs_bugs: {
                name: "Bug reports",
                id: "bugs"
            },
            api_docs_languages: {
                name: "Languages",
                id: "languages"
            },
            api_docs_users: {
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
            api_docs_quizzes: {
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

    def name(array)
        array.last[:name]
    end

    def id(array)
        array.last[:id]
    end

    def subsections?(array)
        array.last[:subsections].present?
    end

    def subsections(array)
        array.last[:subsections]
    end
end

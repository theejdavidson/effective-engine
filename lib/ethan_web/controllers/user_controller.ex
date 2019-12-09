defmodule EthanWeb.UserController do
    use EthanWeb, :controller

    alias Ethan.Accounts
    
    def index(conn, _params) do
        users = Accounts.list_users()
        render(conn, "index.html", users: users)
    end
end
defmodule EthanWeb.UserView do
    use EthanWeb, :view

    alias Ethan.Accounts

    def first_name(%Accounts.User{name: name}) do
        name
        |> String.split(" ")
        |> Enum.at(0)
    end
end
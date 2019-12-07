defmodule Ethan.Repo do
  use Ecto.Repo,
    otp_app: :ethan,
    adapter: Ecto.Adapters.Postgres
end

defmodule Numbers.Repo do
  use Ecto.Repo,
    otp_app: :numbers,
    adapter: Ecto.Adapters.Postgres
end

defmodule Numbers.Game.GameBoard do
  use Ecto.Schema
  import Ecto.Changeset

  schema "game_boards" do
    field :move_count, :integer
    field :size, :integer
    field :tile_board, {:array, {:array, :integer}}
    field :user_uuid, Ecto.UUID

    timestamps()
  end

  @doc false
  def changeset(game_board, attrs) do
    game_board
    |> cast(attrs, [:user_uuid, :size, :move_count, :tile_board])
    |> validate_required([:user_uuid, :size, :move_count, :tile_board])
  end
end

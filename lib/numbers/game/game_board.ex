defmodule Numbers.Game.GameBoard do
  use Ecto.Schema
  import Ecto.Changeset

  alias Numbers.Game.Settings

  schema "game_boards" do
    field :move_count, :integer, default: 0
    field :size, :integer, default: Settings.get(:size)
    field :tile_board, {:array, {:array, :integer}}
    field :user_uuid, Ecto.UUID

    timestamps()
  end

  @doc false
  def changeset(game_board, attrs) do
    game_board
    |> cast(attrs, [:user_uuid, :size, :move_count, :tile_board])
    |> validate_required([:user_uuid, :size, :move_count, :tile_board])
    |> validate_number(:size,
      greater_than_or_equal_to: Settings.get(:minimum_size),
      less_than_or_equal_to: Settings.get(:maximum_size)
    )
  end
end

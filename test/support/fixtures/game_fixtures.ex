defmodule Numbers.GameFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Numbers.Game` context.
  """

  @doc """
  Generate a game_board.
  """
  def game_board_fixture(attrs \\ %{}) do
    {:ok, game_board} =
      attrs
      |> Enum.into(%{
        move_count: 42,
        size: 6,
        tile_board: [[1, 2], [3, 4]],
        user_uuid: "7488a646-e31f-11e4-aace-600308960662"
      })
      |> Numbers.Game.create_game_board()

    game_board
  end
end

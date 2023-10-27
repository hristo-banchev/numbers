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

  @doc """
  Generate a game board that will lose the game on the next move.
  """
  def about_to_lose_game_board_fixture(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      move_count: 178,
      size: 4,
      tile_board: [
        [2, 4, 8, 16],
        [32, 64, 128, 256],
        [2, 4, 8, 16],
        [32, 64, 128, 256]
      ]
    })
    |> game_board_fixture()
  end

  @doc """
  Generate a game board that will win the game on the next move.
  """
  def about_to_win_game_board_fixture(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      move_count: 218,
      size: 4,
      tile_board: [
        [1024, 1024, 8, 16],
        [1024, 1024, 128, 256],
        [2, 4, 8, 16],
        [32, 64, 128, 256]
      ]
    })
    |> game_board_fixture()
  end
end

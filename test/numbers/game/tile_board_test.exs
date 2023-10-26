defmodule Numbers.Game.TileBoardTest do
  use ExUnit.Case

  alias Numbers.Game.TileBoard

  test "blank_tile_board/1 returns a square board in which all tiles are blank" do
    assert TileBoard.blank_tile_board(6) ==
             [
               [nil, nil, nil, nil, nil, nil],
               [nil, nil, nil, nil, nil, nil],
               [nil, nil, nil, nil, nil, nil],
               [nil, nil, nil, nil, nil, nil],
               [nil, nil, nil, nil, nil, nil],
               [nil, nil, nil, nil, nil, nil]
             ]
  end

  test "blank_tile_positions/1 returns the x,y positions of all blank tiles" do
    tile_board = [
      [2, nil, 4],
      [nil, 8, 4],
      [2, 2, nil]
    ]

    assert TileBoard.blank_tile_positions(tile_board) == [[0, 1], [1, 0], [2, 2]]
  end

  test "place_initial_tiles/1 places the first tiles on the tile board" do
    blank_tile_board = TileBoard.blank_tile_board(4)
    start_tiles = 3
    start_tile_value = 4

    initiated_tile_board = TileBoard.place_initial_tiles(blank_tile_board, start_tiles, start_tile_value)

    non_blank_tiles = Enum.flat_map(initiated_tile_board, fn row -> Enum.reject(row, &is_nil/1) end)

    assert length(non_blank_tiles) == start_tiles
    assert Enum.all?(non_blank_tiles, fn tile -> tile == start_tile_value end)
  end

  test "place_new_tile/2 adds a new tile to the board" do
    tile_board = [[nil, 2], [4, nil]]

    {:ok, tile_board} = TileBoard.place_new_tile(tile_board, 2)

    assert length(TileBoard.blank_tile_positions(tile_board)) == 1
  end

  test "place_new_tile/2 returns an error when the board is full" do
    tile_board = [[1, 2], [3, 4]]

    {:error, :full_tile_board} = TileBoard.place_new_tile(tile_board, 2)
  end

  test "move/2 follows the game logic along each direction" do
    tile_board = [
      [2, nil, 2, nil],
      [nil, 2, 2, nil],
      [2, 2, 4, nil],
      [nil, 2, 4, 2]
    ]

    assert TileBoard.move(tile_board, :left) ==
             [
               [4, nil, nil, nil],
               [4, nil, nil, nil],
               [4, 4, nil, nil],
               [2, 4, 2, nil]
             ]

    assert TileBoard.move(tile_board, :right) ==
             [
               [nil, nil, nil, 4],
               [nil, nil, nil, 4],
               [nil, nil, 4, 4],
               [nil, 2, 4, 2]
             ]

    assert TileBoard.move(tile_board, :up) ==
             [
               [4, 4, 4, 2],
               [nil, 2, 8, nil],
               [nil, nil, nil, nil],
               [nil, nil, nil, nil]
             ]

    assert TileBoard.move(tile_board, :down) ==
             [
               [nil, nil, nil, nil],
               [nil, nil, nil, nil],
               [nil, 2, 4, nil],
               [4, 4, 8, 2]
             ]
  end
end

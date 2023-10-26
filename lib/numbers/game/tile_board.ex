defmodule Numbers.Game.TileBoard do
  @moduledoc """
  TODO:
  """

  alias Numbers.Matrix

  @type blank_tile :: nil
  @type tile :: integer() | blank_tile()
  @type tile_board :: list(list(tile()))
  @type direction :: :left | :right | :up | :down

  @doc """
  Returns a blank tile board (a square matrix) with the given size as dimensions.

  ## Examples

      iex> Numbers.Game.blank_tile_board(4)
      [
        [nil, nil, nil, nil],
        [nil, nil, nil, nil],
        [nil, nil, nil, nil],
        [nil, nil, nil, nil]
      ]

  """
  @spec blank_tile_board(integer()) :: tile_board()
  def blank_tile_board(size) when is_integer(size) and size > 0 do
    range = 1..size
    row = Enum.map(range, fn _ -> nil end)
    Enum.map(range, fn _ -> row end)
  end

  @doc """
  Retuns the positions of all blank tiles on the given blank board in the format
  [row, column].

  ## Examples

      iex> tile_board = [[2, nil, 4], [nil, 8, 4], [2, 2, nil]]
      iex> Numbers.Game.blank_tile_positions(tile_board)
      [[0, 1], [1, 0], [2, 2]]

  """
  @spec blank_tile_positions(tile_board()) :: list(list(integer()))
  def blank_tile_positions(tile_board) when is_list(tile_board) do
    tile_board
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, row_index} ->
      row
      |> Enum.with_index()
      |> Enum.filter(fn {value, _} -> is_nil(value) end)
      |> Enum.map(fn {_, column_index} -> [row_index, column_index] end)
    end)
  end

  @doc """
  Places new tiles on a tile board using the game settings.

  ## Examples

      iex> blank_board = Numbers.Game.blank_tile_board(4)
      iex> Numbers.Game.place_initial_tiles(blank_board, 2, 2)
      [
        [nil, nil, nil, nil],
        [nil, nil, 2, nil],
        [2, nil, nil, nil],
        [nil, nil, nil, nil]
      ]

  """
  @spec place_initial_tiles(tile_board(), integer(), tile()) :: tile_board()
  def place_initial_tiles(tile_board, start_tiles, start_tile_value) do
    tile_board
    |> blank_tile_positions()
    |> Enum.shuffle()
    |> Enum.take(start_tiles)
    |> Enum.reduce(tile_board, fn [row, col], board ->
      put_in(board, [Access.at(row), Access.at(col)], start_tile_value)
    end)
  end

  @doc """
  Moves the tiles on the board to the end along the given direction.

  Two equal neighbouring tiles are replaced by a single tile holding their sum.

  For example, consider the row `[nil, 2, nil, 2, 4, nil]`. When performing a
  move to the left, this row would be transformed to `[4, 4, nil, nil, nil, nil]`.
  And when moving to the right, the same row would look like
  `[nil, nil, nil, nil, 4, 4]`.

  Moves to the left and to the right transform all rows on the tile board. Moves
  up and down work in the same manner but using the tile board's columns instead
  of rows.
  """
  @spec move(tile_board(), direction()) :: tile_board()
  def move(tile_board, direction)

  def move(tile_board, :left) do
    Enum.map(tile_board, &sum_neighbours/1)
  end

  def move(tile_board, :right) do
    Enum.map(tile_board, fn row ->
      row
      |> Enum.reverse()
      |> sum_neighbours()
      |> Enum.reverse()
    end)
  end

  def move(tile_board, :up) do
    tile_board
    |> Matrix.transpose()
    |> Enum.map(&sum_neighbours/1)
    |> Matrix.transpose()
  end

  def move(tile_board, :down) do
    tile_board
    |> Matrix.transpose()
    |> Enum.map(fn row ->
      row
      |> Enum.reverse()
      |> sum_neighbours()
      |> Enum.reverse()
    end)
    |> Matrix.transpose()
  end

  ###########
  # Private #
  ###########

  defp sum_neighbours(row) do
    {blank_tiles, compact_row} = Enum.split_with(row, &is_nil/1)

    sum_neighbours(compact_row, [], blank_tiles)
  end

  defp sum_neighbours([], result, blank_tiles), do: Enum.reverse(result, blank_tiles)

  defp sum_neighbours([a, b | rest], result, blank_tiles) when a == b do
    sum_neighbours(rest, [a + b | result], [nil | blank_tiles])
  end

  defp sum_neighbours([a | rest], result, blank_tiles), do: sum_neighbours(rest, [a | result], blank_tiles)
end

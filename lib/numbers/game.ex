defmodule Numbers.Game do
  @moduledoc """
  The Game context.
  """

  import Ecto.Query, warn: false
  alias Numbers.Repo

  alias Numbers.Game.GameBoard
  alias Numbers.Game.Settings
  alias Numbers.Matrix

  @type blank_tile :: nil
  @type tile :: integer() | blank_tile()
  @type tile_board :: list(list(tile()))

  @doc """
  Returns the list of game_boards.

  ## Examples

      iex> list_game_boards()
      [%GameBoard{}, ...]

  """
  def list_game_boards do
    Repo.all(GameBoard)
  end

  @doc """
  Gets a single game_board.

  Raises `Ecto.NoResultsError` if the Game board does not exist.

  ## Examples

      iex> get_game_board!("7488a646-e31f-11e4-aace-600308960662", 123)
      %GameBoard{}

      iex> get_game_board!("7488a646-e31f-11e4-aace-600308960662", 456)
      ** (Ecto.NoResultsError)

  """
  @spec get_game_board!(Ecto.UUID.t(), integer()) :: GameBoard.t() | term()
  def get_game_board!(user_uuid, id), do: Repo.get_by!(GameBoard, id: id, user_uuid: user_uuid)

  @doc """
  Returns the last game board that belongs to the given user UUID.

  Returns `nil` if there are no boards related to the user UUID.

  ## Examples

      iex> get_last_game_board("7488a646-e31f-11e4-aace-600308960662")
      %GameBoard{}
  """
  @spec get_last_game_board(Ecto.UUID.t()) :: GameBoard.t() | term() | nil
  def get_last_game_board(user_uuid) do
    GameBoard
    |> where(user_uuid: ^user_uuid)
    |> last(:id)
    |> Repo.one()
  end

  @doc """
  Creates a game_board.

  ## Examples

      iex> create_game_board(%{field: value})
      {:ok, %GameBoard{}}

      iex> create_game_board(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_game_board(attrs \\ %{}) do
    %GameBoard{}
    |> GameBoard.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a game_board.

  ## Examples

      iex> update_game_board(game_board, %{field: new_value})
      {:ok, %GameBoard{}}

      iex> update_game_board(game_board, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_game_board(%GameBoard{} = game_board, attrs) do
    game_board
    |> GameBoard.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a game_board.

  ## Examples

      iex> delete_game_board(game_board)
      {:ok, %GameBoard{}}

      iex> delete_game_board(game_board)
      {:error, %Ecto.Changeset{}}

  """
  def delete_game_board(%GameBoard{} = game_board) do
    Repo.delete(game_board)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking game_board changes.

  ## Examples

      iex> change_game_board(game_board)
      %Ecto.Changeset{data: %GameBoard{}}

  """
  def change_game_board(%GameBoard{} = game_board, attrs \\ %{}) do
    GameBoard.changeset(game_board, attrs)
  end

  @doc """
  Creates a new board of the given size that belongs to the given user UUID. The
  game board is ready for the player to make their first move.
  """
  @spec start_new_game(Ecto.UUID.t(), integer()) :: {:ok, GameBoard.t()} | {:error, GameBoard.Changeset.t()}
  def start_new_game(user_uuid, size) when is_binary(user_uuid) and is_integer(size) do
    tile_board =
      size
      |> blank_tile_board()
      |> place_initial_tiles(Settings.get(:start_tiles), Settings.get(:start_tile_value))

    attrs = %{
      user_uuid: user_uuid,
      size: size,
      tile_board: tile_board
    }

    create_game_board(attrs)
  end

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
  Moves the number tiles on the game board along the given direction, increments
  the move count and stores the updated game board.

  ## Examples

      iex> make_a_move(game_board, :left)
      {:ok, %GameBoard{}}
  """
  @spec make_a_move(GameBoard.t(), :up | :down | :left | :right) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def make_a_move(%GameBoard{} = game_board, direction) when is_atom(direction) do
    tile_board = execute_move(game_board.tile_board, direction)

    # TODO: add a new tile at a random empty place

    attrs = %{
      tile_board: tile_board,
      move_count: game_board.move_count + 1
    }

    update_game_board(game_board, attrs)
  end

  ###########
  # Private #
  ###########

  # Places new tiles on a tile board using the game settings.
  #
  # ## Examples
  #
  #     iex> blank_board = Numbers.Game.blank_tile_board(4)
  #     iex> Numbers.Game.place_initial_tiles(blank_board, 2, 2)
  #     [
  #       [nil, nil, nil, nil],
  #       [nil, nil, 2, nil],
  #       [2, nil, nil, nil],
  #       [nil, nil, nil, nil]
  #     ]
  #
  @spec place_initial_tiles(tile_board(), integer(), integer()) :: tile_board()
  defp place_initial_tiles(tile_board, start_tiles, start_tile_value) do
    tile_board
    |> blank_tile_positions()
    |> Enum.shuffle()
    |> Enum.take(start_tiles)
    |> Enum.reduce(tile_board, fn [row, col], board ->
      put_in(board, [Access.at(row), Access.at(col)], start_tile_value)
    end)
  end

  defp execute_move(tile_board, :left) do
    Enum.map(tile_board, &sum_neighbours/1)
  end

  defp execute_move(tile_board, :right) do
    Enum.map(tile_board, fn row ->
      row
      |> Enum.reverse()
      |> sum_neighbours()
      |> Enum.reverse()
    end)
  end

  defp execute_move(tile_board, :up) do
    tile_board
    |> Matrix.transpose()
    |> Enum.map(&sum_neighbours/1)
    |> Matrix.transpose()
  end

  defp execute_move(tile_board, :down) do
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

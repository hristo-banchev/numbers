defmodule Numbers.Game do
  @moduledoc """
  The Game context.
  """

  import Ecto.Query, warn: false
  alias Numbers.Repo

  alias Numbers.Game.GameBoard
  alias Numbers.Game.Settings

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

      iex> get_game_board!(123)
      %GameBoard{}

      iex> get_game_board!(456)
      ** (Ecto.NoResultsError)

  """
  def get_game_board!(id), do: Repo.get!(GameBoard, id)

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
end

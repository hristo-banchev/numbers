defmodule Numbers.Game do
  @moduledoc """
  The Game context.
  """

  import Ecto.Query, warn: false
  alias Numbers.Repo

  alias Numbers.Game.GameBoard
  alias Numbers.Game.Settings
  alias Numbers.Game.TileBoard

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
      |> TileBoard.blank_tile_board()
      |> TileBoard.place_initial_tiles(Settings.get(:start_tiles), Settings.get(:start_tile_value))

    attrs = %{
      user_uuid: user_uuid,
      size: size,
      tile_board: tile_board
    }

    create_game_board(attrs)
  end

  @doc """
  Moves the number tiles on the game board along the given direction, increments
  the move count and stores the updated game board.

  ## Examples

      iex> make_a_move(game_board, :left)
      {:ok, %GameBoard{}}

      iex> make_a_move(game_board, :up)
      {:error, :game_lost}
  """
  @spec make_a_move(GameBoard.t(), :up | :down | :left | :right) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()} | {:error, :game_lost}
  def make_a_move(%GameBoard{} = game_board, direction) when is_atom(direction) do
    move_result =
      game_board.tile_board
      |> TileBoard.move(direction)
      |> TileBoard.place_new_tile(Settings.get(:new_tile_value))

    case move_result do
      {:ok, tile_board} ->
        attrs = %{
          tile_board: tile_board,
          move_count: game_board.move_count + 1
        }

        update_game_board(game_board, attrs)

      {:error, :full_tile_board} ->
        {:error, :game_lost}
    end
  end
end

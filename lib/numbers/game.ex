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
  def start_new_game(user_uuid, size, obstacle_count \\ 0) when is_binary(user_uuid) and is_integer(size) do
    tile_board =
      size
      |> TileBoard.blank_tile_board()
      |> TileBoard.place_initial_tiles(obstacle_count, Settings.get(:obstacle_tile_value))
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
          {:ok, Ecto.Schema.t()}
          | {:ok, Ecto.Schema.t(), :game_won}
          | {:error, Ecto.Changeset.t() | :game_lost | :game_already_won}
  def make_a_move(%GameBoard{} = game_board, direction) when is_atom(direction) do
    with false <- TileBoard.has_tile?(game_board.tile_board, Settings.get(:win_condition)),
         tile_board_after_move = TileBoard.move(game_board.tile_board, direction),
         {:ok, updated_tile_board} <- TileBoard.place_new_tile(tile_board_after_move, Settings.get(:new_tile_value)),
         has_won <- TileBoard.has_tile?(updated_tile_board, Settings.get(:win_condition)),
         attrs = %{tile_board: updated_tile_board, move_count: game_board.move_count + 1},
         {:ok, updated_game_board} <- update_game_board(game_board, attrs) do
      if has_won do
        {:ok, updated_game_board, :game_won}
      else
        {:ok, updated_game_board}
      end
    else
      true ->
        {:error, :game_already_won}

      {:error, :full_tile_board} ->
        {:error, :game_lost}

      {:error, _} = error ->
        error
    end
  end
end

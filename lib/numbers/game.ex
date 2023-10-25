defmodule Numbers.Game do
  @moduledoc """
  The Game context.
  """

  import Ecto.Query, warn: false
  alias Numbers.Repo

  alias Numbers.Game.GameBoard

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
end

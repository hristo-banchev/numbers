defmodule Numbers.GameTest do
  use Numbers.DataCase

  alias Numbers.Game

  describe "game_boards" do
    alias Numbers.Game.GameBoard

    import Numbers.GameFixtures

    @invalid_attrs %{move_count: nil, size: nil, tile_board: nil, user_uuid: nil}

    test "list_game_boards/0 returns all game_boards" do
      game_board = game_board_fixture()
      assert Game.list_game_boards() == [game_board]
    end

    test "get_game_board!/1 returns the game_board with given id" do
      game_board = game_board_fixture()
      assert Game.get_game_board!(game_board.id) == game_board
    end

    test "create_game_board/1 with valid data creates a game_board" do
      valid_attrs = %{
        move_count: 42,
        size: 42,
        tile_board: [[1, 2], [nil, 4]],
        user_uuid: "7488a646-e31f-11e4-aace-600308960662"
      }

      assert {:ok, %GameBoard{} = game_board} = Game.create_game_board(valid_attrs)
      assert game_board.move_count == 42
      assert game_board.size == 42
      assert game_board.tile_board == [[1, 2], [nil, 4]]
      assert game_board.user_uuid == "7488a646-e31f-11e4-aace-600308960662"
    end

    test "create_game_board/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Game.create_game_board(@invalid_attrs)
    end

    test "update_game_board/2 with valid data updates the game_board" do
      game_board = game_board_fixture()

      update_attrs = %{
        move_count: 43,
        size: 43,
        tile_board: [[1, 2], [5, 6]],
        user_uuid: "7488a646-e31f-11e4-aace-600308960668"
      }

      assert {:ok, %GameBoard{} = game_board} = Game.update_game_board(game_board, update_attrs)
      assert game_board.move_count == 43
      assert game_board.size == 43
      assert game_board.tile_board == [[1, 2], [5, 6]]
      assert game_board.user_uuid == "7488a646-e31f-11e4-aace-600308960668"
    end

    test "update_game_board/2 with invalid data returns error changeset" do
      game_board = game_board_fixture()
      assert {:error, %Ecto.Changeset{}} = Game.update_game_board(game_board, @invalid_attrs)
      assert game_board == Game.get_game_board!(game_board.id)
    end

    test "delete_game_board/1 deletes the game_board" do
      game_board = game_board_fixture()
      assert {:ok, %GameBoard{}} = Game.delete_game_board(game_board)
      assert_raise Ecto.NoResultsError, fn -> Game.get_game_board!(game_board.id) end
    end

    test "change_game_board/1 returns a game_board changeset" do
      game_board = game_board_fixture()
      assert %Ecto.Changeset{} = Game.change_game_board(game_board)
    end
  end
end

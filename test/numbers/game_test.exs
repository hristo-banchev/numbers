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

    test "get_game_board!/2 returns the game_board with given id" do
      game_board = game_board_fixture()
      assert Game.get_game_board!(game_board.user_uuid, game_board.id) == game_board
    end

    test "get_last_game_board/1 returns the game_board with given id" do
      user_uuid = Ecto.UUID.generate()

      assert Game.get_last_game_board(user_uuid) == nil

      game_board_fixture(user_uuid: user_uuid)
      game_board_fixture(user_uuid: user_uuid)
      last_game_board = game_board_fixture(user_uuid: user_uuid)

      assert Game.get_last_game_board(user_uuid) == last_game_board
    end

    test "create_game_board/1 with valid data creates a game_board" do
      valid_attrs = %{
        move_count: 42,
        size: 6,
        tile_board: [[1, 2], [nil, 4]],
        user_uuid: "7488a646-e31f-11e4-aace-600308960662"
      }

      assert {:ok, %GameBoard{} = game_board} = Game.create_game_board(valid_attrs)
      assert game_board.move_count == 42
      assert game_board.size == 6
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
        size: 7,
        tile_board: [[1, 2], [5, 6]],
        user_uuid: "7488a646-e31f-11e4-aace-600308960668"
      }

      assert {:ok, %GameBoard{} = game_board} = Game.update_game_board(game_board, update_attrs)
      assert game_board.move_count == 43
      assert game_board.size == 7
      assert game_board.tile_board == [[1, 2], [5, 6]]
      assert game_board.user_uuid == "7488a646-e31f-11e4-aace-600308960668"
    end

    test "update_game_board/2 with invalid data returns error changeset" do
      game_board = game_board_fixture()
      assert {:error, %Ecto.Changeset{}} = Game.update_game_board(game_board, @invalid_attrs)
      assert game_board == Game.get_game_board!(game_board.user_uuid, game_board.id)
    end

    test "delete_game_board/1 deletes the game_board" do
      game_board = game_board_fixture()
      assert {:ok, %GameBoard{}} = Game.delete_game_board(game_board)
      assert_raise Ecto.NoResultsError, fn -> Game.get_game_board!(game_board.user_uuid, game_board.id) end
    end

    test "change_game_board/1 returns a game_board changeset" do
      game_board = game_board_fixture()
      assert %Ecto.Changeset{} = Game.change_game_board(game_board)
    end

    test "start_new_game/2 creates a new game board with initial tiles" do
      user_uuid = "7488a646-e31f-11e4-aace-600308960668"
      size = 4

      assert {:ok, %GameBoard{} = game_board} = Game.start_new_game(user_uuid, size)

      assert game_board.move_count == 0
      assert game_board.size == 4
      assert game_board.user_uuid == "7488a646-e31f-11e4-aace-600308960668"

      non_blank_tiles = Enum.flat_map(game_board.tile_board, fn row -> Enum.reject(row, &is_nil/1) end)

      assert length(non_blank_tiles) == Game.Settings.get(:start_tiles)
      assert Enum.all?(non_blank_tiles, fn tile -> tile == Game.Settings.get(:start_tile_value) end)
    end

    test "make_a_move/2 follows the game logic along the left direction" do
      tile_board = [
        [2, nil, 2, nil],
        [nil, 2, 2, nil],
        [2, 2, 4, nil],
        [nil, 2, 4, 2]
      ]

      game_board = game_board_fixture(%{size: 4, tile_board: tile_board, move_count: 0})

      assert {:ok, %GameBoard{} = new_board} = Game.make_a_move(game_board, :left)
      assert new_board.move_count == 1
      assert new_board.tile_board != tile_board
    end

    test "make_a_move/2 follows the game logic along the right direction" do
      tile_board = [
        [2, nil, 2, nil],
        [nil, 2, 2, nil],
        [2, 2, 4, nil],
        [nil, 2, 4, 2]
      ]

      game_board = game_board_fixture(%{size: 4, tile_board: tile_board, move_count: 0})

      assert {:ok, %GameBoard{} = new_board} = Game.make_a_move(game_board, :right)
      assert new_board.move_count == 1
      assert new_board.tile_board != tile_board
    end

    test "make_a_move/2 follows the game logic along the up direction" do
      tile_board = [
        [2, nil, 2, nil],
        [nil, 2, 2, nil],
        [2, 2, 4, nil],
        [nil, 2, 4, 2]
      ]

      game_board = game_board_fixture(%{size: 4, tile_board: tile_board, move_count: 0})

      assert {:ok, %GameBoard{} = new_board} = Game.make_a_move(game_board, :up)
      assert new_board.move_count == 1
      assert new_board.tile_board != tile_board
    end

    test "make_a_move/2 follows the game logic along the down direction" do
      tile_board = [
        [2, nil, 2, nil],
        [nil, 2, 2, nil],
        [2, 2, 4, nil],
        [nil, 2, 4, 2]
      ]

      game_board = game_board_fixture(%{size: 4, tile_board: tile_board, move_count: 0})

      assert {:ok, %GameBoard{} = new_board} = Game.make_a_move(game_board, :down)
      assert new_board.move_count == 1
      assert new_board.tile_board != tile_board
    end

    test "make_a_move/2 wins the game when during the move 2048 is present in the tile board" do
      tile_board = [
        [1024, 1024, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 2]
      ]

      game_board = game_board_fixture(%{size: 4, tile_board: tile_board})

      assert {:ok, won_game_board, :game_won} = Game.make_a_move(game_board, :left)

      assert won_game_board.tile_board ==
               [
                 [2048, 2, 4, 1],
                 [4, 2, 4, 2],
                 [2, 4, 2, 4],
                 [4, 2, 4, 2]
               ]
    end

    test "make_a_move/2 loses the game when no neighbouring tiles can be combined and the board is full" do
      full_tile_board = [
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 2]
      ]

      game_board = game_board_fixture(%{size: 4, tile_board: full_tile_board})

      assert {:error, :game_lost} = Game.make_a_move(game_board, :left)
    end

    test "make_a_move/2 can not be performed when the game has already been won" do
      won_tile_board = [
        [2048, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 2]
      ]

      game_board = game_board_fixture(%{size: 4, tile_board: won_tile_board})

      assert {:error, :game_already_won} = Game.make_a_move(game_board, :left)
    end
  end
end

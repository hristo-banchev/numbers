defmodule NumbersWeb.GameLiveTest do
  require IEx
  use NumbersWeb.ConnCase

  import Phoenix.LiveViewTest
  import Numbers.GameFixtures

  defp make_a_move(game_live, :right) do
    game_live |> element("#game_board") |> render_keyup(%{"key" => "ArrowRight"})
  end

  describe "2048 game board" do
    test "starts a new game when clicking the new game button", %{conn: conn} do
      {:ok, game_live, html} = live(conn, ~p"/")

      assert html =~ "Moves: 0"

      assert make_a_move(game_live, :right) =~ "Moves: 1"

      assert game_live |> element("#new_game") |> render_click() =~ "Moves: 0"
    end

    test "can start a new game with a different board size", %{conn: conn} do
      {:ok, game_live, _html} = live(conn, ~p"/")

      count_tiles = fn game_live ->
        ~r/regular-tile/
        |> Regex.scan(game_live |> element("#game_board") |> render())
        |> Enum.count()
      end

      refute game_live |> element("#size_4") |> render() =~ "disabled=\"disabled\""
      assert game_live |> element("#size_6") |> render() =~ "disabled=\"disabled\""

      game_board_html = game_live |> element("#game_board") |> render()

      refute game_board_html =~ "grid-cols-4"
      assert game_board_html =~ "grid-cols-6"
      assert count_tiles.(game_live) == 36

      game_live |> element("#size_4") |> render_click()
      game_live |> element("#new_game") |> render_click()

      assert game_live |> element("#size_4") |> render() =~ "disabled=\"disabled\""
      refute game_live |> element("#size_6") |> render() =~ "disabled=\"disabled\""

      game_board_html = game_live |> element("#game_board") |> render()

      assert game_board_html =~ "grid-cols-4"
      refute game_board_html =~ "grid-cols-6"
      assert count_tiles.(game_live) == 16
    end

    test "can start a new game with a different number of obstacles", %{conn: conn} do
      {:ok, game_live, _html} = live(conn, ~p"/")

      count_obstacles = fn game_live ->
        ~r/obstacle-tile/
        |> Regex.scan(game_live |> element("#game_board") |> render())
        |> Enum.count()
      end

      assert game_live |> element("#obstacles_0") |> render() =~ "disabled=\"disabled\""
      refute game_live |> element("#obstacles_2") |> render() =~ "disabled=\"disabled\""
      assert count_obstacles.(game_live) == 0

      game_live |> element("#obstacles_2") |> render_click()
      game_live |> element("#new_game") |> render_click()

      refute game_live |> element("#obstacles_0") |> render() =~ "disabled=\"disabled\""
      assert game_live |> element("#obstacles_2") |> render() =~ "disabled=\"disabled\""
      assert count_obstacles.(game_live) == 2
    end

    test "displays a message when the game is over", %{conn: conn} do
      conn = get(conn, ~p"/")

      about_to_lose_game_board_fixture(%{user_uuid: conn.assigns.user_uuid})

      {:ok, game_live, html} = live(conn, ~p"/")

      refute html =~ "Game over!"

      assert make_a_move(game_live, :right) =~ "Game over!"
    end

    test "displays a message when the game is won", %{conn: conn} do
      conn = get(conn, ~p"/")

      about_to_win_game_board_fixture(%{user_uuid: conn.assigns.user_uuid})

      {:ok, game_live, html} = live(conn, ~p"/")

      refute html =~ "You won!"

      assert make_a_move(game_live, :right) =~ "You won!"
    end
  end
end

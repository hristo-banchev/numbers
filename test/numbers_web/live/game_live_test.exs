defmodule NumbersWeb.GameLiveTest do
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

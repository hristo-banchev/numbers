defmodule NumbersWeb.GameLive do
  use NumbersWeb, :live_view

  alias Numbers.Game

  @doc """
  Renders a square tile with its value positioned in the center of the square.
  """
  def render_tile(assigns) do
    ~H"""
    <div class="aspect-square flex items-center justify-center bg-pink-400 border-2 border-slate-800 text-white text-5xl font-bold">
      <%= @tile %>
    </div>
    """
  end

  @impl true
  def mount(_params, session, socket) do
    user_uuid = session["user_uuid"]
    game_board = fetch_current_game_board_or_start_new(user_uuid)

    socket =
      socket
      |> assign(:page_title, "2048 Game")
      |> assign(:user_uuid, user_uuid)
      |> assign(:game_board, game_board)
      |> assign(:selected_size, game_board.size)
      |> assign(:has_won, false)
      |> assign(:has_lost, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("new_board", _params, socket) do
    {:ok, %Game.GameBoard{} = new_game_board} =
      Game.start_new_game(socket.assigns.user_uuid, socket.assigns.selected_size)

    {:noreply, assign(socket, :game_board, new_game_board)}
  end

  @impl true
  def handle_event("control_board", %{"key" => "ArrowUp"}, socket) do
    {:noreply, make_a_move(socket, :up)}
  end

  @impl true
  def handle_event("control_board", %{"key" => "ArrowDown"}, socket) do
    {:noreply, make_a_move(socket, :down)}
  end

  @impl true
  def handle_event("control_board", %{"key" => "ArrowLeft"}, socket) do
    {:noreply, make_a_move(socket, :left)}
  end

  @impl true
  def handle_event("control_board", %{"key" => "ArrowRight"}, socket) do
    {:noreply, make_a_move(socket, :right)}
  end

  @impl true
  def handle_event("control_board", _params, socket) do
    {:noreply, socket}
  end

  ###########
  # Private #
  ###########

  defp fetch_current_game_board_or_start_new(user_uuid) do
    case Game.get_last_game_board(user_uuid) do
      %Game.GameBoard{} = game_board ->
        game_board

      nil ->
        {:ok, %Game.GameBoard{} = new_game_board} =
          Game.start_new_game(user_uuid, Numbers.Game.Settings.get(:default_size))

        new_game_board
    end
  end

  defp make_a_move(socket, direction) do
    case Game.make_a_move(socket.assigns.game_board, direction) do
      {:ok, updated_game_board} ->
        assign(socket, :game_board, updated_game_board)

      {:ok, updated_game_board, :game_won} ->
        socket
        |> assign(:game_board, updated_game_board)
        |> assign(:has_won, true)

      {:error, :game_lost} ->
        assign(socket, :has_lost, true)

      {:error, :game_already_won} ->
        socket
    end
  end
end
defmodule NumbersWeb.GameLive do
  use NumbersWeb, :live_view

  alias Numbers.Game
  alias Numbers.Game.Settings

  @doc """
  Renders a button for changing the size of the game board when starting a new
  game.
  """
  def size_button(assigns) do
    ~H"""
    <button
      id={"size_#{@size}"}
      value={@size}
      phx-click="select_size"
      class="p-4 bg-slate-300 border-2 disabled:opacity-50"
      disabled={@disabled}
    >
      <%= @size %>x<%= @size %>
    </button>
    """
  end

  @doc """
  Renders a button for changing the number of obstacles on the board when
  starting a new game.
  """
  def obstacle_button(assigns) do
    ~H"""
    <button
      id={"obstacles_#{@obstacles}"}
      value={@obstacles}
      phx-click="select_obstacle_count"
      class="p-4 bg-slate-300 border-2 disabled:opacity-50"
      disabled={@disabled}
    >
      <%= @obstacles %>
    </button>
    """
  end

  @doc """
  Renders a square tile with its value positioned in the center of the square.
  """
  def regular_tile(assigns) do
    ~H"""
    <div class="regular-tile aspect-square flex items-center justify-center bg-lime-300 border-4 border-lime-800 text-lime-800 text-5xl font-bold">
      <%= @tile %>
    </div>
    """
  end

  @doc """
  Renders an obstacle square tile.
  """
  def obstacle_tile(assigns) do
    ~H"""
    <div class="obstacle-tile aspect-square flex items-center justify-center bg-red-500 border-4 border-red-800 text-red-800 text-5xl font-bold">
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
      |> assign(:obstacle_count, Settings.get(:default_obstacle_count))
      |> assign(:has_won, false)
      |> assign(:has_lost, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("new_board", _params, socket) do
    {:ok, %Game.GameBoard{} = new_game_board} =
      Game.start_new_game(
        socket.assigns.user_uuid,
        socket.assigns.selected_size,
        socket.assigns.obstacle_count
      )

    {:noreply, assign(socket, :game_board, new_game_board)}
  end

  @impl true
  def handle_event("select_size", %{"value" => new_size}, socket) do
    {:noreply, assign(socket, :selected_size, String.to_integer(new_size))}
  end

  @impl true
  def handle_event("select_obstacle_count", %{"value" => new_obstacle_count}, socket) do
    {:noreply, assign(socket, :obstacle_count, String.to_integer(new_obstacle_count))}
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
          Game.start_new_game(user_uuid, Settings.get(:default_size), Settings.get(:default_obstacle_count))

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

defmodule Numbers.Game.Settings do
  @moduledoc """
  Contains the various settings of the game 2048 like default values, initial
  values, win condition definition, etc. These are for internal use and are not
  meant to be exposed to the player.
  """

  @settings %{
    default_size: 6,
    minimum_size: 4,
    maximum_size: 8,
    win_condition: 2048,
    start_tiles: 1,
    start_tile_value: 2,
    new_tile_value: 1
  }

  def get(setting_key) when is_atom(setting_key), do: @settings[setting_key]
end

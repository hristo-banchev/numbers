defmodule Numbers.Repo.Migrations.CreateGameBoards do
  use Ecto.Migration

  def change do
    create table(:game_boards) do
      add :user_uuid, :uuid, null: false
      add :size, :integer, null: false
      add :move_count, :integer, default: 0, null: false
      add :tile_board, {:array, {:array, :integer}}, null: false

      timestamps()
    end

    create unique_index(:game_boards, [:user_uuid, :id])
  end
end

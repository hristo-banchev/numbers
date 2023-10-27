# Numbers

A variation of the 2048 game I did as a job application project.

## Setup

The application is built with Elixir 1.14.3 and Phoenix 1.7.7. The application also requires access to a running PostgreSQL RDBMS.

To start your Phoenix server:

  * Open `config/dev.exs` and enter your database creadentials
  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser and play the game.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## How to play

Use your arrow keys to move the tiles. Tiles with the same number merge into one when they touch. Add them up to reach 2048!

To start a new game, select the board size and the number of obstacles (immovable tiles) and click on the "New Game" button.

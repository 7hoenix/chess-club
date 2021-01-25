defmodule ChessClub.Chess.Move do
  @moduledoc "Struct for a chess move"

  @enforce_keys [:square_from, :square_to, :color, :move_command, :fen_after_move]
  defstruct [:square_from, :square_to, :color, :move_command, :fen_after_move]
end

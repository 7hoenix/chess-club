defmodule ChessClub.Chess.Move do
  @enforce_keys [:from, :to, :color, :fen_after_move]
  defstruct [:from, :to, :color, :fen_after_move]
end

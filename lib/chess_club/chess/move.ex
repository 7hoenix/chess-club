defmodule ChessClub.Chess.Move do
  @enforce_keys [:square_from, :square_to, :color, :fen_after_move]
  defstruct [:square_from, :square_to, :color, :fen_after_move]
end

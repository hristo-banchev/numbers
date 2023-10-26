defmodule Numbers.MatrixTest do
  use ExUnit.Case

  alias Numbers.Matrix

  describe "transpose/1" do
    test "should transpose the given matrix" do
      matrix = [[1]]

      assert Matrix.transpose(matrix) == matrix

      matrix = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9]
      ]

      assert Matrix.transpose(matrix) == [
               [1, 4, 7],
               [2, 5, 8],
               [3, 6, 9]
             ]
    end
  end
end

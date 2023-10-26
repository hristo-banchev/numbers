defmodule Numbers.Matrix do
  @moduledoc """
  A set of operations on a matrix, represented by a list of lists.
  """

  @type matrix :: list(list())

  @doc """
  Transposes a given matrix.

  ## Examples:

      iex> transpose([[1, 2], [3, 4]])
      [[1, 3], [2, 4]]

  """
  @spec transpose(matrix()) :: matrix()
  def transpose(matrix) when is_list(matrix) do
    # Enum.zip/1 returns a list of tuples. This workaround returns a list of
    # lists instead.
    Enum.zip_with(matrix, &Function.identity/1)
  end
end

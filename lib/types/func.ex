defmodule DryValidation.Types.Func do
  defstruct [:fn]

  def call(%__MODULE__{} = func, value) do
    func.fn.(value)
  end

  def equal(expected) do
    %__MODULE__{
      fn: fn v -> v == expected end
    }
  end
end

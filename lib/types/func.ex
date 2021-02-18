defmodule DryValidation.Types.Func do
  defstruct [:fn, :type]

  def call(%__MODULE__{type: nil} = func, value) do
    func.fn.(value)
  end

  def call(%__MODULE__{type: type} = func, value) do
    value = type.cast(value)
    func.fn.(value)
  end

  def equal(expected) do
    %__MODULE__{
      fn: fn v -> v == expected end
    }
  end
end

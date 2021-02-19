defmodule DryValidation.Types.Func do
  defstruct [:fn, :type]

  def call(%__MODULE__{} = func, value) do
    func.fn.(value)
  end

  def cast(%__MODULE__{type: nil}, value) do
    value
  end

  def cast(%__MODULE__{type: type}, value) do
    type.cast(value)
  end

  def equal(expected) do
    %__MODULE__{
      fn: fn v -> v == expected end
    }
  end

  def member_of(list) when is_list(list) do
    %__MODULE__{
      fn: fn v -> Enum.member?(list, v) end
    }
  end
end

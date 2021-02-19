defmodule DryValidation.Types.Func do
  defstruct [:fn, :type, :error_message]

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
      fn: fn v -> v == expected end,
      error_message: "is not equal to #{inspect(expected)}"
    }
  end

  def member_of(list) when is_list(list) do
    %__MODULE__{
      fn: fn v -> Enum.member?(list, v) end,
      error_message: "is not a member of #{inspect(list)}"
    }
  end
end

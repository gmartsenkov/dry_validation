defmodule DryValidation.Types.Func do
  @moduledoc """
  Provides a way to define custom validation functions.
  It is a struct with:
  * `fn` that stores a function with one argument, that is used validate the input value
  * `type` is optional, used for casting values against that type before validating
  * `error_message` is error message returned in case of failed validation

  ```
  DryValidation.schema do
    required :pet, Types.Func.member_of(["dog", "cat", "bird"])
  end
  ```
  """
  defstruct [:fn, :type, :error_message]

  @doc """
  Validates that the input value is equal to the first argument.
  ```
  DryValidation.schema do
    required :type, Types.Func.equal("user")
  end
  ```
  """
  def equal(expected) do
    %__MODULE__{
      fn: fn v -> v == expected end,
      error_message: "is not equal to #{inspect(expected)}"
    }
  end

  @doc """
  Validates that the value is part of the list.
  ```
  DryValidation.schema do
    required :pet, Types.Func.member_of(["dog", "cat", "bird"])
  end
  ```
  """
  def member_of(list) when is_list(list) do
    %__MODULE__{
      fn: fn v -> Enum.member?(list, v) end,
      error_message: "is not a member of #{inspect(list)}"
    }
  end

  @doc false
  def call(%__MODULE__{} = func, value) do
    func.fn.(value)
  end

  def cast(%__MODULE__{type: nil}, value) do
    value
  end

  def cast(%__MODULE__{type: type}, value) do
    type.cast(value)
  end
end

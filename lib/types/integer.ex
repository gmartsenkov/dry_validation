defmodule DryValidation.Types.Integer do
  @moduledoc """
  Represents an integer type.
  Will try to cast strings into integer values.
  ```
  DryValidation.schema do
    required :age, Types.Integer
  end
  ```
  """
  alias DryValidation.Types.Func

  @doc false
  def cast(value) when is_number(value), do: value

  def cast(value) when is_binary(value) do
    case Integer.parse(value) do
      {number, ""} -> number
      _ -> value
    end
  end

  def cast(value), do: value

  @doc false
  def valid?(value) when is_number(value), do: true
  def valid?(_value), do: false

  @doc """
  Validates that the input value is greater than the value of the first function argument.
  ```
  DryValidation.schema do
    required :age, Types.Integer.greater_than(18)
  end
  ```
  """
  def greater_than(value) do
    %Func{
      fn: fn v -> v > value end,
      type: __MODULE__,
      error_message: "is not greater than #{value}"
    }
  end

  @doc """
  Validates that the input value is greater than or equal to the value of the first function argument.
  ```
  DryValidation.schema do
    required :age, Types.Integer.greater_than_or_equal(18)
  end
  ```
  """
  def greater_than_or_equal(value) do
    %Func{
      fn: fn v -> v >= value end,
      type: __MODULE__,
      error_message: "is not greater than or equal to #{value}"
    }
  end

  @doc """
  Validates that the input value is less than the value of the first function argument.
  ```
  DryValidation.schema do
    required :age, Types.Integer.less_than(100)
  end
  ```
  """
  def less_than(value) do
    %Func{
      fn: fn v -> v < value end,
      type: __MODULE__,
      error_message: "is not less than #{value}"
    }
  end

  @doc """
  Validates that the input value is less than or equal to the value of the first function argument.
  ```
  DryValidation.schema do
    required :age, Types.Integer.less_than_or_equal(100)
  end
  ```
  """
  def less_than_or_equal(value) do
    %Func{
      fn: fn v -> v <= value end,
      type: __MODULE__,
      error_message: "is not less than or equal to #{value}"
    }
  end
end

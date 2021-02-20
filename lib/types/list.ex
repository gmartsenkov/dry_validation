defmodule DryValidation.Types.List do
  @moduledoc """
  Represents a list of elements. Type or a function can also be specified.
  ```
  DryValidation.schema do
    required :words, Types.List.type(Types.String)
    required :numbers, Types.List.type(Types.Integer)
    required :numbers_greater_than_ten, Types.List.type(Types.Integer.greater_than(10))
  end
  ```
  """

  defstruct [:type]

  alias DryValidation.Types

  @doc """
  Specify the required type of the elements within the list.
  """
  def type(type) do
    %Types.List{type: type}
  end

  @doc false
  def call(%Types.List{type: nil}, value) when is_list(value) do
    {:ok, value}
  end

  def call(Types.List, value) when is_list(value) do
    {:ok, value}
  end

  def call(%Types.List{type: %Types.Func{} = func}, value) when is_list(value) do
    value = Enum.map(value, &Types.Func.cast(func, &1))

    invalid_types =
      if func.type,
        do: Enum.reject(value, &func.type.valid?(&1)),
        else: []

    if Enum.empty?(invalid_types) do
      invalid = Enum.reject(value, &Types.Func.call(func, &1))

      if Enum.empty?(invalid),
        do: {:ok, value},
        else: {:error, invalid, func.error_message}
    else
      {:error, invalid_types, "are not of type #{inspect(func.type)}"}
    end
  end

  def call(%Types.List{type: type}, value) when is_list(value) do
    value = Enum.map(value, &type.cast/1)
    invalid = Enum.reject(value, &type.valid?/1)

    if Enum.empty?(invalid),
      do: {:ok, value},
      else: {:error, invalid}
  end

  def call(Types.List, _value), do: {:error, :not_a_list}
  def call(%Types.List{}, _value), do: {:error, :not_a_list}
end

defmodule DryValidation.Types.Bool do
  @moduledoc """
  Represents a boolean type.
  Will cast the strings "true" and "false" into real boolean values.
  ```
  DryValidation.schema do
    required :admin, Types.Bool
  end
  ```
  """
  @doc false
  def cast(value) when is_boolean(value), do: value
  def cast("true"), do: true
  def cast("false"), do: false
  def cast(value), do: value

  @doc false
  def valid?(value) when is_boolean(value), do: true
  def valid?(_value), do: false
end

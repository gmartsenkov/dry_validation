defmodule DryValidation.Types.Date do
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
  def cast(%{__struct__: _date} = value), do: value
  def cast(value) do
    case Date.from_iso8601(value) do
      {:ok, date} -> date
      _ -> value
    end
  end

  @doc false
  def valid?(%{__struct__: _date}), do: true
  def valid?(_value), do: false
end

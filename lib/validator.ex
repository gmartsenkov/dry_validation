defmodule DryValidation.Validator do
  alias DryValidation.Types

  def validate(schema, input) do
    {:ok, pid} = start_agent()

    Enum.each(schema, &walk(&1, input, [], pid))
    result = get_all(pid)

    stop_agent(pid)
    format_result(result)
  end

  defp walk(%{rule: :required, name: name, type: nil}, input, level, pid) do
    value = Map.get(input, name)

    if value,
      do: put_result(pid, level, %{name => value}),
      else: put_error(pid, level, %{name => "Is missing"})
  end

  defp walk(%{rule: :required, name: name, type: type}, input, level, pid) do
    value = Map.get(input, name)

    if value,
      do: validate_and_put_value(type, name, value, level, pid),
      else: put_error(pid, level, %{name => "Is missing"})
  end

  defp walk(%{rule: :optional, name: name, type: type}, input, level, pid) do
    value = Map.get(input, name)

    if value, do: validate_and_put_value(type, name, value, level, pid)
  end

  defp walk(%{rule: :map_list, name: name, optional: true} = rule, input, level, pid) do
    value = Map.get(input, name)

    if value do
      walk(%{rule | optional: false}, input, level, pid)
    end
  end

  defp walk(%{rule: :map_list, name: name, inner: inner, optional: false}, input, level, pid) do
    value = Map.get(input, name)

    if value do
      if is_list(value) do
        result =
          Enum.map(value, fn v ->
            {:ok, nested_pid} = start_agent()

            Enum.each(inner, &walk(&1, v, [], nested_pid))
            result = get_all(nested_pid)

            stop_agent(nested_pid)
            result
          end)

        errors? = Enum.any?(result, fn item -> item.errors != %{} end)

        if errors? do
          final =
            result
            |> Enum.with_index()
            |> Enum.map(fn {item, index} -> [index, item.errors] end)

          put_error(pid, level, %{name => final})
        else
          final = Enum.map(result, fn item -> item.result end)
          put_result(pid, level, %{name => final})
        end
      else
        put_error(pid, level, %{name => "#{inspect(value)} is not a List"})
      end
    else
      put_error(pid, level, %{name => "Is missing"})
    end
  end

  defp walk(%{rule: :map, name: name, inner: inner, optional: false}, input, level, pid) do
    value = Map.get(input, name)

    if value do
      Enum.each(inner, &walk(&1, value, level ++ [name], pid))
    else
      put_error(pid, level, %{name => "Is missing"})
    end
  end

  defp walk(%{rule: :map, name: name, inner: inner, optional: true}, input, level, pid) do
    value = Map.get(input, name)

    if value do
      Enum.each(inner, &walk(&1, value, level ++ [name], pid))
    end
  end

  def validate_and_put_value(Types.List, name, value, level, pid) do
    validate_and_put_value(%Types.List{}, name, value, level, pid)
  end

  def validate_and_put_value(%Types.List{type: type} = list, name, value, level, pid) do
    case Types.List.call(list, value) do
      {:ok, new_value} ->
        put_result(pid, level, %{name => new_value})

      {:error, :not_a_list} ->
        put_error(pid, level, %{name => "#{inspect(value)} is not a List"})

      {:error, invalid_values} ->
        put_error(pid, level, %{
          name => "#{inspect(invalid_values)} are not of type #{inspect(type)}"
        })

      {:error, invalid_values, error_message} ->
        put_error(pid, level, %{
          name => "#{inspect(invalid_values)} #{error_message}"
        })
    end
  end

  def validate_and_put_value(%Types.Func{type: nil} = func, name, value, level, pid) do
    value = Types.Func.cast(func, value)

    if Types.Func.call(func, value) do
      put_result(pid, level, %{name => value})
    else
      put_error(pid, level, %{name => "#{inspect(value)} #{func.error_message}"})
    end
  end

  def validate_and_put_value(%Types.Func{type: type} = func, name, value, level, pid) do
    value = Types.Func.cast(func, value)

    if type.valid?(value) do
      if Types.Func.call(func, value) do
        put_result(pid, level, %{name => value})
      else
        put_error(pid, level, %{name => "#{inspect(value)} #{func.error_message}"})
      end
    else
      put_error(pid, level, %{
        name => "#{inspect(value)} is not a valid type; Expected type is #{inspect(type)}"
      })
    end
  end

  def validate_and_put_value(nil, name, value, level, pid) do
    put_result(pid, level, %{name => value})
  end

  def validate_and_put_value(type, name, value, level, pid) do
    value = type.cast(value)

    if type.valid?(value) do
      put_result(pid, level, %{name => value})
    else
      put_error(pid, level, %{
        name => "#{inspect(value)} is not a valid type; Expected type is #{inspect(type)}"
      })
    end
  end

  def format_result(%{result: result, errors: errors}) when map_size(errors) == 0 do
    {:ok, result}
  end

  def format_result(%{errors: errors}) do
    {:error, errors}
  end

  def put_result(pid, level, map) do
    Agent.update(
      pid,
      fn state ->
        update_in(state, [:result] ++ level, fn result -> Map.merge(result || %{}, map) end)
      end
    )
  end

  def put_error(pid, level, map) do
    Agent.update(
      pid,
      fn state ->
        update_in(state, [:errors] ++ level, fn result -> Map.merge(result || %{}, map) end)
      end
    )
  end

  def get_all(pid) do
    Agent.get(pid, & &1)
  end

  defp start_agent() do
    Agent.start_link(fn ->
      %{result: %{}, errors: %{}}
    end)
  end

  defp stop_agent(pid) do
    Agent.stop(pid)
  end
end

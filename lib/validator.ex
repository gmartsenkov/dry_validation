defmodule DryValidation.Validator do
  def validate(schema, input) do
    {:ok, pid} = start_agent()

    Enum.each(schema, &walk(&1, input, pid))
    result = get_all(pid)

    stop_agent(pid)
    format_result(result)
  end

  defp walk(%{rule: :required, name: name, type: _type}, input, pid) do
    value = Map.get(input, name)
    if value do
      put_result(pid, %{name => value})
    else
      put_error(pid, %{name => "Is missing"})
    end
  end

  defp walk(%{rule: :optional, name: name, type: _type}, input, pid) do
    value = Map.get(input, name)
    if value do
      put_result(pid, %{name => value})
    end
  end

  def format_result(%{result: result, errors: %{}}) do
    {:ok, result}
  end

  def format_result(%{errors: errors}) do
    {:error, errors}
  end

  def put_result(pid, map) do
    Agent.update(
      pid,
      fn state ->
        Map.update!(state, :result, fn result -> Map.merge(result, map) end)
      end
    )
  end

  def put_error(pid, map) do
    Agent.update(
      pid,
      fn state ->
        Map.update!(state, :error, fn result -> Map.merge(result, map) end)
      end
    )
  end

  def get_all(pid) do
    Agent.get(pid, &(&1))
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

defmodule DryValidation do
  defmacro schema(do: block) do
    quote do
      import DryValidation

      {:ok, var!(buffer, __MODULE__)} = start_buffer([])
      unquote(block)
      result = render(var!(buffer, __MODULE__))
      :ok = stop_buffer(var!(buffer, __MODULE__))
      result
    end
  end

  def start_buffer(state), do: Agent.start_link(fn -> state end)

  def stop_buffer(buff), do: Agent.stop(buff)

  def put_buffer(buff, content), do: Agent.update(buff, &[content | &1])

  def render(buff), do: Agent.get(buff, & &1) |> Enum.reverse() |> DryValidation.construct([])

  defmacro map(name, do: inner) do
    quote do
      put_buffer(
        var!(buffer, __MODULE__),
        %{rule: :map, block: :start, name: unquote(name)}
      )

      unquote(inner)

      put_buffer(
        var!(buffer, __MODULE__),
        %{rule: :map, block: :end, name: unquote(name)}
      )
    end
  end

  defmacro required(name, type \\ nil) do
    quote do
      tag(:required, unquote(name), unquote(type))
    end
  end

  defmacro tag(tag, name, type \\ nil) do
    quote do
      put_buffer(
        var!(buffer, __MODULE__),
        %{rule: unquote(tag), name: unquote(name), type: unquote(type)}
      )

      %{name: unquote(name)}
    end
  end

  def construct([%{name: name, block: :start, rule: rule} | tail], result) do
    result ++ [%{name: name, inner: construct(tail, []), rule: rule}]
  end

  def construct([%{block: :end} | _tail], result) do
    result
  end

  def construct([head | tail], result) do
    construct(tail, result ++ [head])
  end

  def construct([], result) do
    result
  end
end

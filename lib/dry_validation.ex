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

  defmacro map(name, opts \\ [], do: inner) do
    quote do
      optional = unquote(Keyword.get(opts, :optional, false))

      put_buffer(
        var!(buffer, __MODULE__),
        %{rule: :map, block: :start, name: unquote(name), optional: optional}
      )

      unquote(inner)

      put_buffer(
        var!(buffer, __MODULE__),
        %{rule: :map, block: :end, name: unquote(name), optional: optional}
      )
    end
  end

  defmacro optional(name, type \\ nil) do
    quote do
      tag(:optional, unquote(name), unquote(type))
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
        %{rule: unquote(tag), name: unquote(to_string(name)), type: unquote(type)}
      )

      %{name: unquote(name)}
    end
  end

  def construct([%{block: :end} | tail], result) do
    construct(tail, result)
  end

  def construct([%{name: name, block: :start, rule: rule, optional: optional} | tail], result) do
    {to_end, rest} = Enum.split_while(tail, fn el ->
      !(Map.get(el, :block) == :end && Map.get(el, :name) == name)
    end)
    inner = construct(to_end, [])

    result = result ++
      [%{name: to_string(name), inner: inner, rule: rule, optional: optional}]

    construct(rest, result)
  end

  def construct([head | tail], result) do
    construct(tail, result ++ [head])
  end

  def construct([], result) do
    result
  end
end

defmodule DryValidation do
  @moduledoc """
  Used to create a schema to validate input data against.
  ## Example
  ```
  iex> alias DryValidation.Types
  ...>
  iex> schema = DryValidation.schema do
  ...>  required :name, Types.String
  ...>  optional :age, Types.Integer
  ...> end
  ...>
  iex> input_data = %{"name" => "John", "age" => "15"}
  iex> {:ok, output_data} = DryValidation.Validator.validate(schema, input_data)
  iex> assert output_data == %{"name" => "John", "age" => 15}
  ...>
  iex> input_data = %{"name" => 15, "age" => "nonsense"}
  iex> {:error, error} = DryValidation.Validator.validate(schema, input_data)
  iex> assert error == %{
  ...>  "name" => "15 is not a valid type; Expected type is DryValidation.Types.String",
  ...>  "age" => ~s("nonsense" is not a valid type; Expected type is DryValidation.Types.Integer)
  ...> }
  ```

  Complex schemas can be crafted using the methods - `required`, `optional`, `map` and `map_list`.
  With the use the provided `DryValidation.Types`, requirements can be set and also cast values when possible.

  ## Available Types
  Type          | Description
  ------------- | -------------
  `DryValidation.Types.String`  | Expects a string type `"some text"`. Will try to cast the value into a string (`1001` = `"1001"`).
  `DryValidation.Types.Bool`    | Expects a boolean type `[true/false]`. Will cast the strings "true"/"false" to real booleans
  `DryValidation.Types.Float`   | Expects a float type `[15.51]`. Will try to cast a string to a float (`"15.5"` = `15.5`).
  `DryValidation.Types.Integer` | Expects an integer type `[101]`. Will try to cast a string to an integer (`"100"` = `100`). It'll fail the cast if the string is a float.
  `DryValidation.Types.Func`    | Custom rules can be build using this, see the module docs. Example is the `DryValidation.Types.Integer.greater_than(5)` rule.
  `DryValidation.Types.List`    | Expects a list. Can have the list type set to one of the above, including a `Func`.
  `DryValidation.Types.Any`     | Accepts any value and will do no casting. Usually not used as the type can just be omitted when using `optional` and `required`

  ## Advanced example
  ```
  schema = DryValidation.schema do
    required :name, Types.String
    required :age, Types.Integer.greater_than(18)
    required :type, Types.Func.equal("users")
    optional :pets, Types.Func.member_of(["dog", "cat", "bird"])
    optional :favourite_numbers, Types.List.type(Types.Integer)

    map_list :cars do
      required :make, Types.String
      required :cc, Types.Integer
    end

    map :house, optional: true do
      required :address, Types.String
    end
  end

  input_data = %{
    "name" => "Jon Snow",
    "age" => 42,
    "type" => "users",
    "pet" => "dog",
    "favourite_numbers" => [],
    "cars" => [
      %{"make" => "AUDI", "cc" => 3000},
      %{"make" => "BMW", "cc" => 2000},
    ],
    "house" => %{
      "address" => "Church Road"
    }
  }
  {:ok, _output_data} = DryValidation.Validator.validate(schema, input_data)
  ```
  """
  @doc """
  Creates a validation schema.
  """
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

  @doc false
  def start_buffer(state), do: Agent.start_link(fn -> state end)

  @doc false
  def stop_buffer(buff), do: Agent.stop(buff)

  @doc false
  def put_buffer(buff, content), do: Agent.update(buff, &[content | &1])

  @doc false
  def render(buff), do: Agent.get(buff, & &1) |> Enum.reverse() |> DryValidation.construct([])

  @doc false
  def last_start_block_id(buff) do
    Agent.get(buff, & &1)
    |> Enum.filter(fn x -> Map.get(x, :block) end)
    |> Enum.map(fn x -> Map.get(x, :id) end)
    |> Enum.max(&>=/2, fn -> 0 end)
  end

  @doc """
  Defines a list of maps. Can be made optional.
  ```
  schema = DryValidation.schema do
    map_list :users, do
      required(:name, Types.String)
    end
  end

  input_data = %{"users" => [%{"name" => "John"}, %{"name" => "Bob"}]}
  {:ok, output_data} = DryValidation.Validator.validate(schema, input_data)
  ```
  """
  defmacro map_list(name, opts \\ [], do: inner) do
    quote do
      map(unquote(name), unquote(Keyword.put(opts, :rule, :map_list)), do: unquote(inner))
    end
  end

  @doc """
  Defines a map. Can be made optional.
  ```
  schema = DryValidation.schema do
    map :user, do
      required(:name, Types.String)
    end

    map :car, optional: true do
      required(:name, Types.String)
    end
  end

  input_data = %{"user" => %{"name" => "John"}}
  {:ok, output_data} = DryValidation.Validator.validate(schema, input_data)
  ```
  """
  defmacro map(name, opts \\ [], do: inner) do
    quote do
      optional = unquote(Keyword.get(opts, :optional, false))
      rule = unquote(Keyword.get(opts, :rule, :map))

      new_id = last_start_block_id(var!(buffer, __MODULE__)) + 1

      put_buffer(
        var!(buffer, __MODULE__),
        %{rule: rule, block: :start, name: unquote(name), optional: optional, id: new_id}
      )

      unquote(inner)

      put_buffer(
        var!(buffer, __MODULE__),
        %{rule: rule, block: :end, name: unquote(name), optional: optional, id: new_id}
      )
    end
  end

  @doc """
    Defines an optional attribute in the schema.
    First argument is the name of the attribute, second argument is optional and defines the type.
    ```
    schema = DryValidation.schema do
      required(:name)
      optional(:age)
    end

    input_data = %{"name" => "Jon"}
    {:ok, output_data} = DryValidation.Validator.validate(schema, input_data)
    output_data == %{"name" => "Jon"}
    ```
  """
  defmacro optional(name, type \\ nil) do
    quote do
      tag(:optional, unquote(name), unquote(type))
    end
  end

  @doc """
    Defines a mandatory attribute in the schema.
    First argument is the name of the attribute, second argument is optional and defines the type.
    ```
    schema = DryValidation.schema do
      required(:name, Types.String)
      optional(:age)
    end

    input_data = %{"age" => 21}
    {:error, errors} = DryValidation.Validator.validate(schema, input_data)
    errors == %{"name" => "Is missing"}
    ```
  """
  defmacro required(name, type \\ nil) do
    quote do
      tag(:required, unquote(name), unquote(type))
    end
  end

  @doc false
  defmacro tag(tag, name, type \\ nil) do
    quote do
      put_buffer(
        var!(buffer, __MODULE__),
        %{rule: unquote(tag), name: unquote(to_string(name)), type: unquote(type)}
      )

      %{name: unquote(name)}
    end
  end

  @doc false
  def construct([%{block: :end} | tail], result) do
    construct(tail, result)
  end

  @doc false
  def construct(
        [%{name: name, block: :start, rule: rule, optional: optional, id: id} | tail],
        result
      ) do
    {to_end, rest} =
      Enum.split_while(tail, fn el ->
        !(Map.get(el, :block) == :end && Map.get(el, :id) == id)
      end)

    inner = construct(to_end, [])

    result =
      result ++
        [%{name: to_string(name), inner: inner, rule: rule, optional: optional}]

    construct(rest, result)
  end

  @doc false
  def construct([head | tail], result) do
    construct(tail, result ++ [head])
  end

  def construct([], result) do
    result
  end
end

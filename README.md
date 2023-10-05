# DryValidation
[![Hex.pm](https://img.shields.io/hexpm/v/dry_validation.svg)](https://hex.pm/packages/dry_validation)
[![CircleCI](https://circleci.com/gh/gmartsenkov/dry_validation.svg?style=svg)](https://circleci.com/gh/gmartsenkov/dry_validation)

Provides a DSL to define complex validation schemas, with the ability to cast values, define custom validation rules and much more.

## Installation

```elixir
def deps do
  [
    {:dry_validation, "~> 1.0"}
  ]
end
```

## Example
  ```elixir
  require DryValidation
  alias DryValidation.Types
  
  schema = DryValidation.schema do
    required :name, Types.String
    optional :age, Types.Integer
  end
  
  input_data = %{"name" => "John", "age" => "15"}
  {:ok, output_data} = DryValidation.Validator.validate(schema, input_data)
  assert output_data == %{"name" => "John", "age" => 15}
  
  input_data = %{"name" => 15, "age" => "nonsense"}
  {:error, error} = DryValidation.Validator.validate(schema, input_data)
  assert error == %{
    "name" => "15 is not a valid type; Expected type is DryValidation.Types.String",
    "age" => ~s("nonsense" is not a valid type; Expected type is DryValidation.Types.Integer)
  }
  ```

  Complex schemas can be crafted using the methods - `required`, `optional`, `map` and `map_list`.
  With the use the provided `DryValidation.Types`, requirements can be set and also cast values when possible.

  ## Available Types
  Type          | Description
  ------------- | -------------
  `DryValidation.Types.String`  | Expects a string type `"some text"`. Will try to cast the value into a string (`1001` = `"1001"`).
  `DryValidation.Types.Bool`    | Expects a boolean type `[true/false]`. Will cast the strings "true"/"false" to real booleans
  `DryValidation.Types.Date`    | Expects a date type `~U[2023-01-20]`. Will try to cast the value into a a date using `Date.from_iso8601`.
  `DryValidation.Types.Float`   | Expects a float type `[15.51]`. Will try to cast a string to a float (`"15.5"` = `15.5`).
  `DryValidation.Types.Integer` | Expects an integer type `[101]`. Will try to cast a string to an integer (`"100"` = `100`). It'll fail the cast if the string is a float.
  `DryValidation.Types.Func`    | Custom rules can be build using this, see the module docs. Example is the `DryValidation.Types.Integer.greater_than(5)` rule.
  `DryValidation.Types.List`    | Expects a list. Can have the list type set to one of the above, including a `Func`.
  `DryValidation.Types.Any`     | Accepts any value and will do no casting. Usually not used as the type can just be omitted when using `optional` and `required`

  ## Advanced example
  ```elixir
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
Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/dry_validation](https://hexdocs.pm/dry_validation).


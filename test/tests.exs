defmodule BongoTest do
  use ExUnit.Case

  # Store the bytecode so we can get information from it.
  {:module, _name, bytecode_model, _exports} =
    defmodule NonCollectionTestModel do
      use Bongo.Model,
          is_collection: false

      model do
        field :int, :integer, :integer, enforce: false
        field :string, :string, :string, enforce: false
        field :string_with_default, :string, :string, default: "default"
        field :mandatory_int, :integer, :integer, enforce: true
      end

      def enforce_keys, do: @enforce_keys
    end

  {:module, _name, bytecode_collection, _exports} =
    defmodule TestModel do
      use Bongo.Model,
          collection: "test_collection"

      model do
        field :int, :integer, :integer
        field :string, :string, :string
      end
    end

  @bytecode bytecode_model
  @bytecode_opaque bytecode_collection

  ## Standard cases

  test "generates the struct with its defaults" do
    assert NonCollectionTestModel.__struct__() == %NonCollectionTestModel{
             int: nil,
             string: nil,
             string_with_default: "default",
             mandatory_int: nil
           }
  end

  test "enforces keys for fields with `enforce: true`" do
    assert NonCollectionTestModel.enforce_keys() == [:mandatory_int]
  end

  test "generates a type for the struct" do
    # Define a second struct with the type expected for TestStruct.
    {:module, _name, bytecode2, _exports} =
      defmodule TestStruct2 do
        defstruct [:int, :string, :string_with_default, :mandatory_int]

        @type t() :: %__MODULE__{
                       int: integer() | nil,
                       string: String.t() | nil,
                       string_with_default: String.t(),
                       mandatory_int: integer()
                     }
      end

    # Get both types and standardise them (remove line numbers and rename
    # the second struct with the name of the first one).
    type1 = @bytecode
            |> extract_first_type()
            |> standardise()

    type2 =
      bytecode2
      |> extract_first_type()
      |> standardise(BongoTest.TestStruct2)

    assert type1 == type2
  end

  test "generates a function to get the struct keys" do
    assert NonCollectionTestModel.__keys__() == [
             :int,
             :string,
             :string_with_default,
             :mandatory_int
           ]
  end

  test "generates a function to get the struct defaults" do
    assert NonCollectionTestModel.__defaults__() == [
             int: nil,
             string: nil,
             string_with_default: "default",
             mandatory_int: nil
           ]
  end

  test "generates a function to get the struct types" do
    types =
      quote do
        [
          int: :integer | nil,
          string: :string | nil,
          string_with_default: :string,
          mandatory_int: :integer
        ]
      end

    assert delete_context(NonCollectionTestModel.__in_types__()) ==
             delete_context(types)
  end

  ## Problems

  test "the name of a field must be an atom" do
    assert_raise ArgumentError, "a field name must be an atom, got 3", fn ->
      defmodule InvalidStruct do
        use Bongo.Model

        model do
          field 3, :integer, :integer
        end
      end
    end
  end

  test "it is not possible to add twice a field with the same name" do
    assert_raise ArgumentError, "the field :name is already set", fn ->
      defmodule InvalidStruct do
        use Bongo.Model

        model do
          field :name, :string, :string
          field :name, :integer, :integer
        end
      end
    end
  end

  ##
  ## Helpers
  ##

  @elixir_version Version.parse!(System.version())
  @min_version Version.parse!("1.7.0-rc")

  # Extracts the first type from a module.
  # NOTE: We define the function differently depending on the Elixir version to
  # avoid compiler warnings.
  if Version.compare(@elixir_version, @min_version) == :lt do
    # API for Elixir 1.6 (TODO: Remove when 1.6 compatibility is dropped.)
    defp extract_first_type(bytecode, type_keyword \\ :type) do
      bytecode
      |> Kernel.Typespec.beam_types()
      |> Keyword.get(type_keyword)
    end
  else
    # API for Elixir 1.7
    defp extract_first_type(bytecode, type_keyword \\ :type) do
      case Code.Typespec.fetch_types(bytecode) do
        {:ok, types} -> Keyword.get(types, type_keyword)
        _ -> nil
      end
    end
  end

  # Standardises a type (removes line numbers and renames the struct to the
  # standard struct name).
  defp standardise(type_info, struct \\ @standard_struct_name)

  defp standardise({name, type, params}, struct) when is_tuple(type),
       do: {name, standardise(type, struct), params}

  defp standardise({:type, _, type, params}, struct),
       do: {:type, :line, type, standardise(params, struct)}

  defp standardise({:remote_type, _, params}, struct),
       do: {:remote_type, :line, standardise(params, struct)}

  defp standardise({:atom, _, struct}, struct),
       do: {:atom, :line, @standard_struct_name}

  defp standardise({type, _, litteral}, _struct),
       do: {type, :line, litteral}

  defp standardise(list, struct) when is_list(list),
       do: Enum.map(list, &standardise(&1, struct))

  # Deletes the context from a quoted expression.
  defp delete_context(list) when is_list(list),
       do: Enum.map(list, &delete_context/1)

  defp delete_context({a, b}),
       do: {delete_context(a), delete_context(b)}

  defp delete_context({fun, _context, args}),
       do: {delete_context(fun), [], delete_context(args)}

  defp delete_context(other), do: other
end

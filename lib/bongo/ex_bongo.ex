defmodule Bongo.Model do
  @moduledoc """
  Bongo.Model is a library for defining structs with a type without writing
  boilerplate code.

  ## Rationale

  To define a struct in Elixir, you probably want to define three things:

    * the struct itself, with default values,
    * the list of enforced keys,
    * its associated type.

  It ends up in something like this:

      defmodule Person do
        @moduledoc \"\"\"
        A struct representing a person.
        \"\"\"

        @enforce_keys [:name]
        defstruct name: nil,
                  age: nil,
                  happy?: true,
                  phone: nil

        @typedoc "A person"
        @type t() :: %__MODULE__{
                name: String.t(),
                age: non_neg_integer() | nil,
                happy?: boolean(),
                phone: String.t() | nil
              }
      end

  In the example above you can notice several points:

    * the keys are present in both the `defstruct` and type definition,
    * enforced keys must also be written in `@enforce_keys`,
    * if a key has no default value and is not enforced, its type should be
      nullable.

  If you want to add a field in the struct, you must therefore:

    * add the key with its default value in the `defstruct` list,
    * add the key with its type in the type definition.

  If the field is not optional, you should even add it to `@enforce_keys`. This
  is way too much work for lazy people like me, and moreover it can be
  error-prone.

  It would be way better if we could write something like this:

      defmodule Person do
        @moduledoc \"\"\"
        A struct representing a person.
        \"\"\"

        use Bongo.Model

        @typedoc "A person"
        model do
          field :name, String.t(), enforce: true
          field :age, non_neg_integer()
          field :happy?, boolean(), default: true
          field :phone, String.t()
        end
      end

  Thanks to Bongo.Model, this is now possible :)

  ## Usage

  ### Setup

  To use Bongo.Model in your project, add this to your Mix dependencies:

      {:typed_struct, "~> #{Mix.Project.config()[:version]}"}

  If you do not plan to compile modules using Bongo.Model at runtime, you can
  add `runtime: false` to the dependency tuple as Bongo.Model is only used
  during compilation.

  If you want to avoid `mix format` putting parentheses on field definitions,
  you can add to your `.formatter.exs`:

      [
        ...,
        import_deps: [:typed_struct]
      ]

  ### General usage

  To define a bongo model, use `Bongo.Model`, then define your struct within a
  `model` block:

      defmodule MyModel do
        # Use Bongo.Model to import the model macro.
        use Bongo.Model

        # Define your struct.
        model do
          # Define each field with the field macro.
          field :a_string, String.t()

          # You can set a default value.
          field :string_with_default, String.t(), default: "default"

          # You can enforce a field.
          field :enforced_field, integer(), enforce: true
        end
      end

  Each field is defined through the `field/2` macro.

  If you want to enforce all the keys by default, you can do:

      defmodule MyStruct do
        use Bongo.Model

        # Enforce keys by default.
        model enforce: true do
          # This key is enforced.
          field :enforced_by_default, term()

          # You can override the default behaviour.
          field :not_enforced, term(), enforce: false

          # A key with a default value is not enforced.
          field :not_enforced_either, integer(), default: 1
        end
      end

  You can also generate an opaque type for the struct:

      defmodule MyOpaqueStruct do
        use Bongo.Model

        # Generate an opaque type for the struct.
        model opaque: true do
          field :name, String.t()
        end
      end

  ### Documentation

  To add a `@typedoc` to the struct type, just add the attribute above the
  `model` block:

      @typedoc "A typed struct"
      model do
        field :a_string, String.t()
        field :an_int, integer()
      end

  ### Reflexion

  To enable the use of information defined by Bongo.Model by other modules, each
  typed struct defines three functions:

    * `__keys__/0` - returns the keys of the struct
    * `__defaults__/0` - returns the default value for each field
    * `__types__/0` - returns the quoted type for each field

  For instance:

      iex(1)> defmodule Demo do
      ...(1)>   use Bongo.Model
      ...(1)>
      ...(1)>   model do
      ...(1)>     field :a_field, String.t()
      ...(1)>     field :with_default, integer(), default: 7
      ...(1)>   end
      ...(1)> end
      {:module, Demo,
      <<70, 79, 82, 49, 0, 0, 8, 60, 66, 69, 65, 77, 65, 116, 85, 56, 0, 0, 0, 241,
        0, 0, 0, 24, 11, 69, 108, 105, 120, 105, 114, 46, 68, 101, 109, 111, 8, 95,
        95, 105, 110, 102, 111, 95, 95, 9, 102, ...>>, {:__types__, 0}}
      iex(2)> Demo.__keys__()
      [:a_field, :with_default]
      iex(3)> Demo.__defaults__()
      [a_field: nil, with_default: 7]
      iex(4)> Demo.__types__()
      [
        a_field: {:|, [],
        [
          {{:., [line: 5],
            [{:__aliases__, [line: 5, counter: -576460752303422524], [:String]}, :t]},
            [line: 5], []},
          nil
        ]},
        with_default: {:integer, [line: 6], []}
      ]

  ## What do I get?

  When defining an empty `model` block:

      defmodule Example do
        use Bongo.Model

        model do
        end
      end

  you get an empty struct with its module type `t()`:

      defmodule Example do
        @enforce_keys []
        defstruct []

        @type t() :: %__MODULE__{}
      end

  Each `field` call adds information to the struct, `@enforce_keys` and the type
  `t()`.

  A field with no options adds the name to the `defstruct` list, with `nil` as
  default. The type itself is made nullable:

      defmodule Example do
        use Bongo.Model

        model do
          field :name, String.t()
        end
      end

  becomes:

      defmodule Example do
        @enforce_keys []
        defstruct name: nil

        @type t() :: %__MODULE__{
                name: String.t() | nil
              }
      end

  The `default` option adds the default value to the `defstruct`:

      field :name, String.t(), default: "John Smith"

      # Becomes
      defstruct name: "John Smith"

  When set to `true`, the `enforce` option enforces the key by adding it to the
  `@enforce_keys` attribute.

      field :name, String.t(), enforce: true

      # Becomes
      @enforce_keys [:name]
      defstruct name: nil

  In both cases, the type has no reason to be nullable anymore by default. In
  one case the field is filled with its default value and not `nil`, and in the
  other case it is enforced. Both options would generate the following type:

      @type t() :: %__MODULE__{
            name: String.t() # Not nullable
          }

  Passing `opaque: true` replaces `@type` with `@opaque` in the struct type
  specification:

      model opaque: true do
        field :name, String.t()
      end

      # Becomes

      @opaque t() :: %__MODULE__{
                name: String.t()
              }
  """

  @doc false
  defmacro __using__(opts) do
    quote location: :keep do
      Module.put_attribute(__MODULE__, :connection, unquote(opts[:connection]))

      Module.put_attribute(
        __MODULE__,
        :default_opts,
        unquote(opts[:default_opts])
      )

      Module.put_attribute(
        __MODULE__,
        :collection_name,
        unquote(opts[:collection_name])
      )

      import Bongo.Converter.In, only: [into: 3]
      import Bongo.Converter.Out, only: [from: 4]
      import Bongo.Utilities, only: [filter_nils: 1, to_struct: 2, nill: 2]
      import Bongo.Model, only: [model: 1, model: 2]

      import Bongo.Filters,
        only: [
          sort: 1,
          sort: 2,
          project: 1,
          project: 2,
          limit: 1,
          limit: 2,
          skip: 1,
          skip: 2,
          upsert: 1,
          upsert: 2
        ]

      def normalize(value) when is_list(value) do
        Enum.map(value, &normalize(&1))
      end

      def structize(value, lenient) when is_list(value) do
        Enum.map(value, &structize(&1, lenient))
      end

      def normalize(value) do
        case is_valid(value) do
          true ->
            value
            |> into(
              __MODULE__.__in_types__(),
              __MODULE__.__defaults__()
            )
            |> filter_nils()
            |> Map.merge(
              case Enum.member?(__MODULE__.__keys__(), :_id) do
                true -> %{_id: Mongo.object_id()}
                false -> %{}
              end
            )

          false ->
            raise "Not of correct type"
        end
      end

      def structize(value, lenient) do
        resp =
          value
          |> from(
            __MODULE__.__out_types__(),
            __MODULE__.__defaults__(),
            lenient
          )
          |> filter_nils()
          |> Map.new()

        case lenient do
          true -> Map.merge(value, resp)
          false -> to_struct(__MODULE__, resp)
        end
      end

      defp add_many!(obj, opts \\ []) do
        case is_valid(obj) do
          true -> add_many_raw!(normalize(obj), opts)
          false -> raise "Not a valid obj"
        end
      end

      defp add!(obj, opts \\ []) do
        case is_valid(obj) do
          true -> add_raw!(normalize(obj), opts)
          false -> raise "Not a valid obj"
        end
      end

      defp find_one(query \\ %{}, opts \\ []) do
        item = find_one_raw(structize(query, true), opts)
        nill(item, structize(item, false))
      end

      defp find(query \\ %{}, opts \\ []) do
        item = find_raw(structize(query, true), opts)
        nill(item, structize(item, false))
      end

      defp update!(query, update, opts \\ []) do
        update_raw!(
          structize(query, true),
          Enum.map(update, fn {k, v} -> {k, structize(v, true)} end),
          opts
        )
      end

      defp update_many!(query, update, opts \\ []) do
        update_many_raw!(
          structize(query, true),
          Enum.map(update, fn {k, v} -> {k, structize(v, true)} end),
          opts
        )
      end

      defp remove!(query, opts \\ []) do
        Mongo.delete_many!(
          @connection,
          @collection_name,
          query,
          @default_opts
          |> Keyword.merge(opts)
        )
      end

      defp find_one_raw(query \\ %{}, opts \\ []) do
        Mongo.find_one(
          @connection,
          @collection_name,
          query,
          @default_opts
          |> Keyword.merge(opts)
        )
      end

      defp add_raw!(obj, opts \\ []) do
        Mongo.insert_one!(
          @connection,
          @collection_name,
          obj,
          @default_opts
          |> Keyword.merge(opts)
        )
      end

      defp add_many_raw!(obj, opts \\ []) do
        Mongo.insert_many!(
          @connection,
          @collection_name,
          obj,
          @default_opts
          |> Keyword.merge(opts)
        )
      end

      defp find_raw(query \\ %{}, opts \\ []) do
        Mongo.find(
          @connection,
          @collection_name,
          query,
          @default_opts
          |> Keyword.merge(opts)
        )
        |> Enum.to_list()
      end

      defp update_many_raw!(query, update, opts \\ []) do
        Mongo.update_many!(
          @connection,
          @collection_name,
          query,
          update,
          @default_opts
          |> Keyword.merge(opts)
        )
      end

      defp update_raw!(query, update, opts \\ []) do
        Mongo.update_one!(
          @connection,
          @collection_name,
          query,
          update,
          @default_opts
          |> Keyword.merge(opts)
        )
      end

      def is_valid(%mod{} = items) when is_list(items) do
        !Enum.find(items, &(!is_valid(&1)))
      end

      def is_valid(%mod{} = _) do
        mod == __MODULE__
      end

      def is_valid(_) do
        false
      end
    end
  end

  @doc """
  Defines a typed struct.

  Inside a `model` block, each field is defined through the `field/2`
  macro.

  ## Options

    * `enforce` - if set to true, sets `enforce: true` to all fields by default.
      This can be overridden by setting `enforce: false` or a default value on
      individual fields.
    * `opaque` - if set to true, creates an opaque type for the struct

  ## Examples

      defmodule MyStruct do
        use Bongo.Model

        model do
          field :field_one, String.t()
          field :field_two, integer(), enforce: true
          field :field_three, boolean(), enforce: true
          field :field_four, atom(), default: :hey
        end
      end

  This is the same as writing:

      defmodule MyStruct do
        use Bongo.Model

        model enforce: true do
          field :field_one, String.t(), enforce: false
          field :field_two, integer()
          field :field_three, boolean()
          field :field_four, atom(), default: :hey
        end
      end
  """
  defmacro model(opts \\ [], do: block) do
    quote do
      Module.register_attribute(__MODULE__, :fields, accumulate: true)
      Module.register_attribute(__MODULE__, :in_types, accumulate: true)
      Module.register_attribute(__MODULE__, :out_types, accumulate: true)
      Module.register_attribute(__MODULE__, :keys_to_enforce, accumulate: true)
      Module.put_attribute(__MODULE__, :enforce?, unquote(!!opts[:enforce]))

      import Bongo.Model
      unquote(block)

      @enforce_keys @keys_to_enforce
      defstruct @fields

      Bongo.Model.__type__(List.flatten([@in_types, @out_types]), unquote(opts))

      def __keys__,
        do:
          @fields
          |> Keyword.keys()
          |> Enum.reverse()

      def __defaults__, do: Enum.reverse(@fields)
      def __in_types__, do: Enum.reverse(@in_types)
      def __out_types__, do: Enum.reverse(@out_types)
    end
  end

  @doc """
  Defines a field in a typed struct.

  ## Example

      # A field named :example of type String.t()
      field :example, String.t()

  ## Options

    * `default` - sets the default value for the field
    * `enforce` - if set to true, enforces the field and makes its type
      non-nullable
  """
  defmacro field(name, in_type, out_type, opts \\ []) do
    quote do
      Bongo.Model.__field__(
        __MODULE__,
        unquote(name),
        unquote(Macro.escape(in_type)),
        unquote(Macro.escape(out_type)),
        unquote(opts)
      )
    end
  end

  ##
  ## Callbacks
  ##

  @doc false
  def __field__(mod, name, in_type, out_type, opts) when is_atom(name) do
    if mod
       |> Module.get_attribute(:fields)
       |> Keyword.has_key?(name) do
      raise ArgumentError, "the field #{inspect(name)} is already set"
    end

    default = opts[:default]

    enforce? =
      if is_nil(opts[:enforce]),
        do: Module.get_attribute(mod, :enforce?) && is_nil(default),
        else: !!opts[:enforce]

    nullable? = !default && !enforce?

    Module.put_attribute(mod, :fields, {name, default})
    Module.put_attribute(mod, :in_types, {name, type_for(in_type, nullable?)})
    Module.put_attribute(mod, :out_types, {name, type_for(out_type, nullable?)})
    if enforce?, do: Module.put_attribute(mod, :keys_to_enforce, name)
  end

  def __field__(_mod, name, _in_type, _out_type, _opts) do
    raise ArgumentError, "a field name must be an atom, got #{inspect(name)}"
  end

  @doc false
  defmacro __type__(types, opts) do
    if Keyword.get(opts, :opaque, false) do
      quote bind_quoted: [
              types: types
            ] do
        @opaque t() :: %__MODULE__{unquote_splicing(types)}
      end
    else
      quote bind_quoted: [
              types: types
            ] do
        @type t() :: %__MODULE__{unquote_splicing(types)}
      end
    end
  end

  ##
  ## Helpers
  ##

  # Makes the type nullable if the key is not enforced.
  defp type_for(type, false), do: type
  defp type_for(type, _), do: quote(do: unquote(type) | nil)
end

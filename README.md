# Bongo

Elegant mongodb object modeling for elixir

Usage
```elixir
use Bongo.Model,
    connection: {mongo_config_atom},
    default_opts: [
      pool: {poolboy}
    ],
    collection_name: {collection_name}
```

defaults_opts could be an empty list


declare a model
```elixir
  @typedoc "A User"
  @derive Jason.Encoder
  model do
    field(:_id, BSON.ObjectId.t(), String.t(), enforce: false)
    field(:handle, String.t(), String.t(), enforce: true)
    field(:items, [Models.Product.t()], [Models.Product.t()])

    field(:created_at, Integer.t(), Integer.t(),
      default: [DateUtils, :current_time_in_seconds, []]
    )
  end
```

a model contains declarations of fields

fields need to be passed a name, the type in which it will be saved into the db,
the type in which it will be written on querying and optional [default | enforce] values

right now it accepts String| Integer | BSON.ObjectId | any other bongo models you have used

the default value can be a function call in this format 
```elixir
[model, function_name_atom, args]
```

```elixir
field(:field1, in_type.t(), out_type.t(), enforce: true)
field(:field2, Integer.t(), Integer.t(), default: 10)
field(:field3, AnotherBongoModel.t(), AnotherBongoModel.t(), default: 10)
field(:field3, AnotherBongoModel.t(), AnotherBongoModel.t(), default: [AnotherBongoModel, :default_object_generator, []])
```

in your models module you can declare functions to access the db 
```elixir
  def find_limited(query, limit) do
    find(
      query,
      limit(limit)
    )
  end
```


the available private functions inside your module are 
```elixir
add_many!
add!
find_one
find
remove!
update_many_raw!
update_raw!

#try not to use the below ones
find_one_raw
add_raw!
add_many_raw!
find_raw
```

other useful functions generated in your module and are publicly available

```elixir
normalize
structize
is_valid
```


Built on top of the great work by ejpcmac [https://github.com/ejpcmac/typed_struct]


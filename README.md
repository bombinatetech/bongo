# Bongo

Elegant mongodb object modeling for elixir

add to deps
```elixir
      {:bongo, git: "https://github.com/bombinatetech/bongo", tag: "v0.0.8" },
      {:mongodb}
```

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
    field(:_id, :objectId, :string, enforce: false)
    field(:handle, :string, :string, enforce: true)
    field(:items, [Models.Product.t()], [Models.Product.t()])

    field(:created_at, :integer, :integer,
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

all available types
```elixir
:string
:integer
:objectId
:boolean
:float
:double
:any
```

```elixir
field(:field1, in_type.t(), out_type.t(), enforce: true)
field(:field2, :integer, :integer, default: 10)
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
update!
update_many!

#try not to use the below ones
update_many_raw!
update_raw!
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


### model generator

You can generate the models even if they have nested models by passing a map 
to this generator function
```elixir
user = %{
   name: "Ramu Kaka",
   age: 13,
   address: %{
      city: "bangalore",
      country: "India"
     }
   }
   
Bongo.MapToModel.generate_model_for("user", user)
```
this Generates two files user.ex and address.ex and embeds the address type


Built on top of the great work by ejpcmac [https://github.com/ejpcmac/typed_struct]


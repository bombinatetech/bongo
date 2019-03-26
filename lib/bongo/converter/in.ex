defmodule Bongo.Converter.In do
  import Bongo.Utilities, only: [log_and_return: 2, debug_log: 2, debug_log: 1]

  def convert_in(<<36 :: utf8, mongo_operation :: binary>>, value, type, lenient) do
    debug_log(type, "<<36, _rest :: binary>> = key, value, type, _lenient")
    case mongo_operation do
      "elemMatch" -> convert_in(
                       value,
                       case type do
                         [e] -> e
                         o -> o
                       end,
                       lenient
                     )
      _ -> convert_in(value, type, lenient)
    end
  end

  def convert_in(_key, value, type, lenient) do
    debug_log("key, value, type, lenient")
    convert_in(value, type, lenient)
  end

  def convert_in(nil, type, _lenient) do
    debug_log(type, "nil, type, _lenient : type = ")
    nil
  end

  def convert_in(value, nil, _lenient) do
    debug_log(nil, "value, nil, _lenient : type = ")
    log_and_return(value, "This model contains an unknown field *in* type")
  end

  def convert_in(value, {:mongo_internal, in_types, default, opts}, lenient) do
    Enum.map(value, &into(&1, in_types, default, opts, lenient))
  end

  def convert_in(value, {:|, [], [type, nil]}, lenient) do
    debug_log(type, "value, {:|, [], [type, nil]}, lenient: type = ")
    convert_in(value, type, lenient)
  end

  def convert_in(
        value,
        {{:., line, [{:__aliases__, _aliases, type}, :t]}, line, []},
        lenient
      ) do
    debug_log(
      type,
      "value,{{:., line, [{:__aliases__, _aliases, type}, :t]}, line, []},
      lenient : type = "
    )

    convert_in(
      value,
      Macro.expand_once({:__aliases__, [alias: false], type}, __ENV__),
      lenient
    )
  end

  def convert_in(value, [type], lenient)
      when is_list(value) do
    debug_log(type, "value, [type], lenient : type = ")
    Enum.map(value, &convert_in(&1, type, lenient))
  end

  def convert_in(value, type, lenient) when is_list(value) do
    debug_log(type, "value, type, lenient when is_list(value) : type = ")

    value
    |> Enum.map(&convert_in(&1, type, lenient))
  end

  def convert_in(%i_module{} = value, module, lenient) do
    debug_log(:module, "value, module, lenients : normalize into = ")
    module.normalize(value, lenient)
  rescue
    _ ->
      debug_log(
        {i_module, module, value},
        "failed to normalize {i_module,module,value} "
      )
         value
  end

  def convert_in(%{} = value, type, lenient) do
    debug_log(type, "value, type, lenient : type = ")

    value
    |> Enum.map(&foreach_map(&1, type, lenient))
    |> Map.new()
  end

  def convert_in([model, func, args] = _, _, _) do
    debug_log({model, func}, "[model, func, args] = _, _, _ : fn = ")
    apply(model, func, args)
  end

  def convert_in(value, :string, _lenient) do
    debug_log(:string, "value, :string, _lenient : type = ")
    to_string(value)
  end

  def convert_in(value, :integer, _lenient) do
    debug_log(:integer, "value, :integer, _lenient : type = ")
    cond do
      is_number(value) -> value
      true -> Integer.parse(to_string(value))
    end
  end

  def convert_in(%BSON.ObjectId{} = value, :objectId, _lenient) do
    debug_log(:objectId, "%BSON.ObjectId{} = value, :objectId, _lenient : type = ")
    value
  end

  def convert_in(value, :objectId, _lenient) do
    debug_log(:objectId, "value, :objectId, _lenient : type = ")
    BSON.ObjectId.decode!(value)
  end

  def convert_in(value, :boolean, _lenient) do
    debug_log(:boolean, "value, :boolean, _lenient : type = ")

    case is_boolean(value) do
      true -> value
      false -> nil
    end
  end

  def convert_in(value, :double, _lenient) do
    value
  end

  def convert_in(value, :float, _lenient) do
    value
  end

  def convert_in(value, :any, _lenient) do
    value
  end

  # fixme what if we reached here as a dead end ? safely check this brooo

  def into(item, in_types, defaults, opts, lenient) do
    defaults = case lenient do
      true -> []
      false -> defaults
    end
    in_types ++ [
      "$or": {:mongo_internal, in_types, defaults, opts},
      "$and": {:mongo_internal, in_types, defaults, opts}
    ]
    |> Enum.map(fn {k, v} ->
      {
        k,
        item
        |> Map.get(k, Keyword.get(defaults, k))
        |> convert_in(v, lenient)
      }
    end)
    |> Map.new()
    |> Bongo.Utilities.nil_filter(opts)
  end

  def foreach_map({k, v}, type, lenient) do
    debug_log({to_string(k), v, type, lenient}, "foreach")
    {k, convert_in(to_string(k), v, type, lenient)}
  end
end

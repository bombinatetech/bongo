defmodule Bongo.Converter.In do
  import Bongo.Utilities, only: [log_and_return: 2]

  @debug false

  defmacrop debug_log(value, label) do
    if @debug do
      quote do
        IO.inspect(inspect(unquote(value)), label: unquote(label))
      end
    end
  end

  def convert_in(nil, type, _lenient) do
    debug_log(type, "nil, type, _lenient : type = ")
    nil
  end

  def convert_in(value, nil, _lenient) do
    debug_log(nil, "value, nil, _lenient : type = ")
    log_and_return(value, "This model contains an unknown field *in* type")
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
    |> Enum.map(fn v -> convert_in(v, type, lenient) end)
  end

  def convert_in(value, type, lenient)
      when is_map(value) do
    debug_log(type, "value, type, lenient when is_map(value) : type = ")

    value
    |> Enum.map(fn {k, v} -> {k, convert_in(v, type, lenient)} end)
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

  # fixme what if we reached here as a dead end ? safely check this brooo
  def convert_in(value, module, lenient) do
    debug_log(:module, "value, module, lenients : normalize into = ")
    module.normalize(value, lenient)
  end

  def into(item, in_types, defaults, lenient) do
    in_types
    |> Enum.map(fn {k, v} ->
      {
        k,
        item
        |> Map.get(k, Keyword.get(defaults, k))
        |> convert_in(v, lenient)
      }
    end)
    |> Map.new()
  end
end

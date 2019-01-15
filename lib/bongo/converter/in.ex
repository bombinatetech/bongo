defmodule Bongo.Converter.In do
  import Bongo.Utilities, only: [nill: 2, log_and_return: 1, log_and_return: 2]

  def convert_in(nil, type, lenient) do
    nil
  end

  def convert_in(value, nil, lenient) do
    log_and_return(value, "This model contains an unknown field *in* type")
  end

  def convert_in(value, {:|, [], [type, nil]}, lenient) do
    convert_in(value, type, lenient)
  end

  def convert_in(
        value,
        {{:., line, [{:__aliases__, _aliases, type}, :t]}, line, []},
        lenient
      ) do
    convert_in(
      value,
      Macro.expand_once({:__aliases__, [alias: false], type}, __ENV__),
      lenient
    )
  end

  def convert_in(value, [type], lenient)
      when is_list(value) do
    Enum.map(value, &convert_in(&1, type, lenient))
  end

  def convert_in(value, type, lenient) when is_map(value) do
    value
    |> Enum.map(fn {k, v} -> {k, convert_in(value, type, lenient)} end)
    |> Map.new()
  end

  def convert_in(value, type, lenient) when is_list(value) do
    value
    |> Enum.map(fn {k, v} -> {k, convert_in(value, type, lenient)} end)
  end

  def convert_in([model, func, args] = _, _, lenient) do
    apply(model, func, args)
  end

  def convert_in(value, :string, _lenient) do
    to_string(value)
  end

  def convert_in(value, :integer, _lenient) do
    value
  end

  def convert_in(value, :objectId, _lenient) do
    BSON.ObjectId.decode!(value)
  end

  def convert_in(value, :boolean, _lenient) do
    case is_boolean(value) do
      true -> value
      false -> nil
    end
  end

  # fixme what if we reached here as a dead end ? safely check this brooo
  def convert_in(value, module, lenient) do
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

defmodule Bongo.Converter.Out do
  @moduledoc false

  import Bongo.Utilities, only: [nill: 2, log_and_return: 1, log_and_return: 2]

  def convert_out(value, {:|, [], [type, nil]}, lenient) do
    nill(value, convert_out(value, type, lenient))
  end

  def convert_out(
        value,
        {{:., line, [{:__aliases__, _aliases, type}, :t]}, line, []},
        lenient
      ) do
    nill(
      value,
      convert_out(
        value,
        Macro.expand_once({:__aliases__, [alias: false], type}, __ENV__),
        lenient
      )
    )
  end

  def convert_out(
        value,
        [{{:., line, [{:__aliases__, _aliases, type}, :t]}, line, []}],
        lenient
      )
      when is_list(value) do
    nill(
      value,
      Enum.map(
        value,
        &convert_out(
          &1,
          Macro.expand_once(
            {:__aliases__, [alias: false], type},
            __ENV__
          ),
          lenient
        )
      )
    )
  end

  def convert_out(value, [type], lenient) when is_list(value) do
    nill(value, Enum.map(value, &convert_out(&1, type, lenient)))
  end

  def convert_out(%BSON.ObjectId{} = value, :string, _lenient) do
    nill(value, BSON.ObjectId.encode!(value))
  end

  def convert_out(value, :string, _lenient) do
    nill(value, to_string(value))
  end

  def convert_out(value, :integer, _lenient) do
    nill(value, value)
  end

  def convert_out(value, :objectId, _lenient) do
    nill(value, BSON.ObjectId.decode!(value))
  end

  def convert_out(value, :boolean, _lenient) do
    case is_boolean(value) do
      true -> value
      false -> nil
    end
  end

  def convert_out(value, nil, _lenient) do
    log_and_return(value, "This model contains an unknown field *out* type ")
  end

  def convert_out(value, module, lenient) do
    nill(value, module.structize(value, lenient))
  end

  def from(item, out_types, _defaults, lenient) do
    Map.merge(
      case lenient do
        true -> item
        false -> %{}
      end,
      Enum.map(item, fn {k, v} ->
        case Keyword.has_key?(out_types, String.to_atom(k)) do
          true ->
            {k, convert_out(v, out_types[String.to_atom(k)], lenient)}

          false ->
            {k, :blackhole}
        end
      end)
    )
  end
end

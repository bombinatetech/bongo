defmodule Bongo.Converter.Out do
  import Bongo.Utilities, only: [log_and_return: 2, debug_log: 2]

  def convert_out(nil, _type, _lenient) do
    nil
  end

  def convert_out(value, nil, _lenient) do
    log_and_return(value, "This model contains an unknown field *out* type")
  end

  def convert_out(value, {:|, [], [type, nil]}, lenient) do
    convert_out(value, type, lenient)
  end

  def convert_out(
        value,
        {{:., line, [{:__aliases__, _aliases, type}, :t]}, line, []},
        lenient
      ) do
    convert_out(
      value,
      Macro.expand_once({:__aliases__, [alias: false], type}, __ENV__),
      lenient
    )
  end

  def convert_out(value, [type], lenient)
      when is_list(value) do
    Enum.map(value, &convert_out(&1, type, lenient))
  end

  #  def convert_out(value, type, lenient) when is_list(value) do
  #    value
  #    |> Enum.map(fn {k, v} -> {k, convert_out(v, type, lenient)} end)
  #  end
  #
  #  def convert_out(value, type, lenient) when is_map(value) do
  #    value
  #    |> Enum.map(fn {k, v} -> {k, convert_out(v, type, lenient)} end)
  #    |> Map.new()
  #  end

  def convert_out(%BSON.ObjectId{} = value, :string, _lenient) do
    BSON.ObjectId.encode!(value)
  end

  def convert_out(value, :string, _lenient) do
    to_string(value)
  end

  def convert_out(value, :integer, _lenient) do
    cond do
      is_number(value) -> value
      is_binary(value) -> case value
                               |> to_string
                               |> Integer.parse do
                            {number, _extra} -> number
                            :error -> value
                          end
      true -> case value
                   |> inspect
                   |> Integer.parse do
                {number, _extra} -> number
                :error -> value
              end
    end
  end

  def convert_out(%BSON.ObjectId{} = value, :objectId, _lenient) do
    value
  end

  def convert_out(value, :objectId, _lenient) do
    BSON.ObjectId.decode!(value)
  end

  def convert_out(value, :boolean, _lenient) do
    case is_boolean(value) do
      true -> value
      false -> nil
    end
  end

  def convert_out(value, :any, _lenient) do
    value
  end

  def convert_out(value, :float, _lenient) do
    value
  end

  def convert_out(value, :double, _lenient) do
    value
  end

  # fixme what if we reached here as a dead end ? safely check this brooo
  def convert_out(value, module, lenient) do
    module.structize(value, lenient)
  rescue
    _ -> debug_log({module, value}, "failed to structize {module,value} ")
         value
  end

  def from(item, out_types, _defaults, lenient) do
    Enum.map(
      item,
      fn {k, v} ->
        atom = k
               |> to_string
               |> String.to_atom
        case Keyword.has_key?(out_types, atom) do
          true ->
            {k, convert_out(v, out_types[atom], lenient)}
          false ->
            {k, :blackhole}
        end
      end
    )
  end
end

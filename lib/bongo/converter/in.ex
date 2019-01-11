defmodule Bongo.Converter.In do
  import Bongo.Utilities, only: [nill: 2, log_and_return: 1, log_and_return: 2]

  def convert_in(value, {:|, [], [type, nil]}, lenient) do
    nill(value, convert_in(value, type, lenient))
  end

  def convert_in(
        value,
        {{:., line, [{:__aliases__, _aliases, type}, :t]}, line, []},
        lenient
      ) do
    nill(
      value,
      convert_in(
        value,
        Macro.expand_once({:__aliases__, [alias: false], type}, __ENV__),
        lenient
      )
    )
  end

  def convert_in(
        value,
        [{{:., line, [{:__aliases__, _aliases, type}, :t]}, line, []}],
        lenient
      )
      when is_list(value) do
    nill(
      value,
      Enum.map(
        value,
        &convert_in(
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

  def convert_in([model, func, args] = _, _, lenient) do
    apply(model, func, args)
  end

  def convert_in(value, [type], lenient) when is_list(value) and is_atom(type) do
    nill(value, Enum.map(value, &convert_in(&1, type, lenient)))
  end

  def convert_in(value, :string, lenient) do
    value
  end

  def convert_in(value, :integer, lenient) do
    value
  end

  def convert_in(value, :objectId, lenient) do
    nill(value, BSON.ObjectId.decode!(value))
  end

  def convert_in(value, :boolean, lenient) do
    value
  end

  def convert_in(value, nil, lenient) do
    log_and_return(value, "This model contains an unknown field *in* type")
  end

  def convert_in(value, module, lenient) do
    nill(value, module.normalize(value, lenient))
  end

  def into(item, in_types, defaults, lenient) do
    Enum.map(
      in_types,
      fn {k, v} ->
        {
          k,
          convert_in(Map.get(item, k, Keyword.get(defaults, k)), v, lenient)
        }
      end
    )
    |> Enum.into(%{})
  end
end

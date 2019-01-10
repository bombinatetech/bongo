defmodule Bongo.Converter.In do
  import Bongo.Utilities, only: [nill: 2, log_and_return: 1, log_and_return: 2]

  def convert_in(value, {:|, [], [type, nil]}) do
    nill(value, convert_in(type, value))
  end

  def convert_in(
        value,
        {{:., line, [{:__aliases__, _aliases, type}, :t]}, line, []}
      ) do
    nill(
      value,
      convert_in(
        value,
        Macro.expand_once({:__aliases__, [alias: false], type}, __ENV__)
      )
    )
  end

  def convert_in(
        value,
        [{{:., line, [{:__aliases__, _aliases, type}, :t]}, line, []}]
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
          )
        )
      )
    )
  end

  def convert_in([model, func, args] = _, _) do
    apply(model, func, args)
  end

  def convert_in(value, [type]) when is_list(value) and is_atom(type) do
    nill(value, Enum.map(value, &convert_in(&1, type)))
  end

  def convert_in(value, :string) do
    value
  end

  def convert_in(value, :integer) do
    value
  end

  def convert_in(value, :objectId) do
    BSON.ObjectId.decode!(value)
  end

  def convert_in(value, :boolean) do
    value
  end

  def convert_in(value, nil) do
    log_and_return(value, "This model contains an unknown field *in* type")
  end

  def convert_in(value, module) do
    module.normalize(value)
  end

  def into(item, in_types, defaults) do
    Enum.map(
      in_types,
      fn {k, v} ->
        {
          k,
          convert_in(Map.get(item, k, Keyword.get(defaults, k)), v)
        }
      end
    )
    |> Enum.into(%{})
  end
end

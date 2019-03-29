defmodule Bongo.MapToModel do
  def type(k, v) do
    type_text = type_raw(k, v)
    "\t\tfield(:#{k}, #{type_text}, enforce: true)\n"
  end

  def type_raw(k, v) do
    cond do
      is_boolean(v) ->
        ":boolean, :boolean"

      is_integer(v) ->
        ":integer, :integer"

      is_float(v) -> ":float, :float"

      is_object_id(v) ->
        ":objectId, :string"

      is_list(v) ->
        cond do
          length(v) > 0 ->
            first_item = Enum.at(v, 0)
            type = type_raw(k, first_item)
            type
            |> String.split(", ")
            |> Enum.map(&("[#{&1}]"))
            |> Enum.join(", ")

          true ->
            "[:any], [:any]"
        end

      is_map(v) ->
        new_mod = generate_model_for(k, v, false)
        "#{new_mod}.t(), #{new_mod}.t()"

      String.valid?(v) ->
        ":string, :string"

      true ->
        ":any, :any"
    end
  end

  def is_object_id(%BSON.ObjectId{} = _v) do
    true
  end

  def is_object_id(_) do
    false
  end

  def generate_model_for(pmodel_name, model, is_collection \\ true) do
    fields = Enum.map(model, fn {k, v} -> type(k, v) end)
    model_name = "Models.#{String.capitalize(to_string(pmodel_name))}"
    collection_name = String.downcase(to_string(pmodel_name))
    config_text =
      case is_collection do
        true -> "[collection_name: \"#{collection_name}\"]"
        false -> "[is_collection: false]"
      end

    File.write!(
      "#{collection_name}.ex",
      """
      defmodule #{model_name} do
      \tuse Bongo.Model, #{config_text}\n
      \tmodel do
      #{fields}
      \tend
      end
      """
    )
    model_name
  end
end

defmodule Bongo.MapToModel do
  def type(k, v) do
    type_text =
      cond do
        is_boolean(v) ->
          ":boolean, :boolean"

        is_integer(v) ->
          ":integer, :integer"

        is_float(v) -> ":float, :float"

        OkApi.Util.is_object_id?(v) ->
          ":objectId, :string"

        is_list(v) ->
          cond do
            length(v) > 0 ->
              new_mod = generate_model_for(k, Enum.at(v, 0), false)
              "[#{new_mod}.t()], [#{new_mod}.t()]"

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

    "field(:#{k}, #{type_text}, enforce: true)\n"
  end

  def generate_model_for(pmodel_name, model, is_collection \\ true) do
    fields = Enum.map(model, fn {k, v} -> type(k, v) end)
    model_name = "Models.#{String.capitalize(pmodel_name)}"
    collection_name = String.downcase(pmodel_name)
    config_text = ""

    if is_collection do
      config_text =
        "[collection_name: \"#{collection_name}\",is_collection: false]"
    else
      config_text = "[is_collection: false]"
    end

    File.write!(
      "#{pmodel_name}.ex",
      """
      defmodule #{model_name} do
        use Bongo.Model, #{config_text}

        @derive Jason.Encoder
        model do
          #{fields}
        end
      end
      """
    )
    model_name
  end
end

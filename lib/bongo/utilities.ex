defmodule Bongo.Utilities do
  def to_struct(kind, attrs) do
    struct = struct(kind)

    Enum.reduce(
      Map.to_list(struct),
      struct,
      fn {k, _}, acc ->
        case Map.fetch(attrs, Atom.to_string(k)) do
          {:ok, v} -> %{acc | k => v}
          :error -> acc
        end
      end
    )
  end

  def filter_nils(nil) do
    nil
  end

  def filter_nils(keyword) when is_list(keyword) do
    Enum.reject(keyword, fn {_key, value} ->
      is_nil(value) or value == :blackhole
    end)
  end

  def filter_nils(map) when is_map(map) do
    Enum.reject(map, fn {_key, value} ->
      is_nil(value) or value == :blackhole
    end)
    |> Enum.into(%{})
  end

  defmacro nill(value, block, lenient \\ false) do
    quote location: :keep do
      case unquote(value) do
        nil ->
          nil

        _ ->
          case lenient do
            true -> value
            false -> unquote(block)
          end
      end
    end
  end

  def log_and_return(o, label \\ "") do
    IO.inspect(inspect(o), label: label)
    o
  end
end

defmodule Bongo.Utilities do

  @debug false

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
        nil -> nil
        _ -> unquote(block)
      end
    end
  end

  def log_and_return(o, label \\ "") do
    IO.inspect(inspect(o), label: label)
    o
  end

  defmacro debug_log(value, label) do
    if @debug do
      quote do
        IO.inspect(inspect(unquote(value)), label: unquote(label))
      end
    end
  end
end

defmodule Bongo.Utilities do

  @debug false

  def to_struct(kind, attrs) do
    struct = struct(kind)
    struct
    |> Map.to_list()
    |> Enum.reduce(
      struct,
      fn {k, _}, acc ->
        case {Map.fetch(attrs, Atom.to_string(k)), Map.fetch(attrs, k)} do
          {{:ok, v1}, {:ok, v2}} -> %{acc | k => v2}
          #fixme v1 or v2 what to take bruh ?
          {{:ok, v}, :error} -> %{acc | k => v}
          {:error, {:ok, v}} -> %{acc | k => v}
          {:error, :error} -> acc
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

  defmacro nill(value, block, block_on_nil \\ nil) do
    quote location: :keep do
      case unquote(value) do
        nil -> unquote(block_on_nil)
        _ -> unquote(block)
      end
    end
  end


  def nil_filter(input, opts) do
    case opts[:filter_nils] != false do
      true -> filter_nils(input)
      false -> input
    end
  end

  def log_and_return(o, label \\ "") do
    IO.inspect(inspect(o), label: label)
    o
  end

  defmacro debug_log(value, label \\ "->") do
    if @debug do
      quote do
        IO.inspect(inspect(unquote(value)), label: unquote(label))
      end
    end
  end
end

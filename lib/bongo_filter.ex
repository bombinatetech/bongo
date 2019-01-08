defmodule Bongo.Filters do
  def sort(key) do
    [sort: key]
  end

  def sort(opts, key) do
    opts
    |> Keyword.merge(sort: key)
  end

  def project(key) do
    [projection: key]
  end

  def project(opts, key) do
    opts
    |> Keyword.merge(projection: key)
  end

  def limit(key) do
    [limit: key]
  end

  def limit(opts, key) do
    opts
    |> Keyword.merge(limit: key)
  end

  def skip(key) do
    [skip: key]
  end

  def skip(opts, key) do
    opts
    |> Keyword.merge(skip: key)
  end

  def upsert(bool) do
    [upsert: bool]
  end

  def upsert(opts, bool) do
    opts
    |> Keyword.merge(upsert: bool)
  end
end

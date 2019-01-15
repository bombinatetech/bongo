defmodule Bongo.Filters do
  def sort(key) do
    [sort: key]
  end

  def sort(opts, key) do
    opts ++ sort(key)
  end

  def project(key) do
    [projection: key]
  end

  def project(opts, key) do
    opts ++ project(key)
  end

  def limit(key) do
    [limit: key]
  end

  def limit(opts, key) do
    opts ++ limit(key)
  end

  def skip(key) do
    [skip: key]
  end

  def skip(opts, key) do
    opts ++ skip(key)
  end

  def upsert(bool) do
    [upsert: bool]
  end

  def upsert(opts, bool) do
    opts ++ upsert(bool)
  end
end

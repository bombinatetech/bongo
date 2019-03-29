defmodule Test.Model do
  @moduledoc false
  use Bongo.Model, is_collection: false

  model do
    field(:lol, :string, :string)
  end

end

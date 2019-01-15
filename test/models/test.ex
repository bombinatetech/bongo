defmodule Models.Test do
  use Bongo.Model

  model do
    field(:shoot,:boolean,:boolean,enforce: true)
  end
end

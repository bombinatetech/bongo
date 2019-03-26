defmodule Model.Test do
  use Bongo.Model, is_collection: true

  @typedoc "A UserNotificationPreferences"
  @derive Jason.Encoder
  model do
    field(:_id, :objectId, :string)
    field(:user_id, :objectId, :string, default: "5bd1ddfe00f1632be7024d0f")
    field(:time_slot_start_hour, :integer, :integer)
    field(:time_slot_end_hour, :integer, :integer)
    field(:optin_days, [:integer], [:integer])
  end



  def get_qualifying_users_for_slots(day, hour) do
    Model.Test.normalize(
      %{
        "$or": [
          %{
            time_slot_start_hour: %{
              "$lte": hour
            }
          },
          %{
            time_slot_end_hour: %{
              "$gt": hour
            }
          }
        ],
        optin_days: %{
          "$elemMatch": day
        },
        time_slot_start_hour: %{
          "$lte": hour
        },
        time_slot_end_hour: %{
          "$nin": ["5bd1ddfe00f1632be7024d0f", "5bd1ddfe00f1632be7024d0f", "5bd1ddfe00f1632be7024d0f"]
        }
      },
      true,
      []
    )
  end
end

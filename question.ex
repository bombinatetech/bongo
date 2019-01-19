defmodule Models.Question do
	use Bongo.Model, [collection_name: "question",is_collection: false]

	@derive Jason.Encoder
	model do
		field(:push_notification, :any, :any, enforce: true)
		field(:ref_id, :string, :string, enforce: true)
		field(:source, :string, :string, enforce: true)
		field(:n_vokes, :float, :float, enforce: true)
		field(:description, :any, :any, enforce: true)
		field(:image_share, :any, :any, enforce: true)
		field(:_id, :string, :string, enforce: true)
		field(:score, :float, :float, enforce: true)
		field(:created_at, :integer, :integer, enforce: true)
		field(:modified_at, :integer, :integer, enforce: true)
		field(:type, :any, :any, enforce: true)
		field(:language, :string, :string, enforce: true)
		field(:title, :string, :string, enforce: true)
		field(:status, :integer, :integer, enforce: true)
		field(:share_url, :string, :string, enforce: true)
		field(:location, :any, :any, enforce: true)
		field(:default_text, :string, :string, enforce: true)
		field(:allow_voke, :integer, :integer, enforce: true)
		field(:n_plays, :integer, :integer, enforce: true)
		field(:answers, [Models.Answers.t()], [Models.Answers.t()], enforce: true)
		field(:voice_desc, :string, :string, enforce: true)
		field(:voice_desc_opus, :string, :string, enforce: true)
		field(:image, :any, :any, enforce: true)
		field(:n_views, :integer, :integer, enforce: true)
		field(:creator, :string, :string, enforce: true)
		field(:is_in_sitemap, :boolean, :boolean, enforce: true)
		field(:slug_generated, :boolean, :boolean, enforce: true)
		field(:hashtag, [:string], [:string], enforce: true)
		field(:needs_expert, :boolean, :boolean, enforce: true)
		field(:is_timeless, :integer, :integer, enforce: true)
		field(:dash_status, :integer, :integer, enforce: true)
		field(:is_in_archive, :boolean, :boolean, enforce: true)
		field(:weightage, :integer, :integer, enforce: true)
		field(:parent_topic_id, :any, :any, enforce: true)

	end
end

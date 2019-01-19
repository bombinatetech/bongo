defmodule Models.Answers do
	use Bongo.Model, [is_collection: false]

	@derive Jason.Encoder
	model do
		field(:transcribed_text_summary, :string, :string, enforce: true)
		field(:n_comments, :integer, :integer, enforce: true)
		field(:n_likes, :integer, :integer, enforce: true)
		field(:score, :integer, :integer, enforce: true)
		field(:video_upload_source, :any, :any, enforce: true)
		field(:created_at, :integer, :integer, enforce: true)
		field(:modified_at, :any, :any, enforce: true)
		field(:type, :string, :string, enforce: true)
		field(:topic_id, :any, :any, enforce: true)
		field(:payload_opus, :string, :string, enforce: true)
		field(:title, :string, :string, enforce: true)
		field(:owner_id, :string, :string, enforce: true)
		field(:status, :integer, :integer, enforce: true)
		field(:content_id, :string, :string, enforce: true)
		field(:n_plays, :integer, :integer, enforce: true)
		field(:transcribed_text_inserted_at, :integer, :integer, enforce: true)
		field(:attr, :string, :string, enforce: true)
		field(:video_hls_url, :any, :any, enforce: true)
		field(:certificate, :any, :any, enforce: true)
		field(:samplerate, :any, :any, enforce: true)
		field(:is_comment, :string, :string, enforce: true)
		field(:video_url, :string, :string, enforce: true)
		field(:lang, :string, :string, enforce: true)
		field(:n_shares, :integer, :integer, enforce: true)
		field(:img, :string, :string, enforce: true)
		field(:anonymous, :integer, :integer, enforce: true)
		field(:transcribed_text_modified_at, :integer, :integer, enforce: true)
		field(:duration, :integer, :integer, enforce: true)
		field(:transcribed_text, :string, :string, enforce: true)
		field(:meta_tags, :string, :string, enforce: true)
		field(:transcription_status, :string, :string, enforce: true)
		field(:priority, :any, :any, enforce: true)
		field(:category, :any, :any, enforce: true)
		field(:video_meta, :any, :any, enforce: true)
		field(:reference, :integer, :integer, enforce: true)
		field(:payload, :string, :string, enforce: true)

	end
end

class Rdv::FirstStep
  include ActiveModel::Model

  attr_accessor :motif, :organisation, :duration_in_min, :start_at, :max_users_limit, :location, :user, :pros
  validates :motif, :organisation, presence: true

  def rdv
    Rdv.new(organisation: organisation,
      motif: motif,
      user: user,
      location: location,
      pros: pros || [],
      duration_in_min: duration_in_min,
      start_at: start_at,
      max_users_limit: max_users_limit,
      name: "#{user&.full_name} <> #{motif&.name}")
  end

  def to_query
    {
      motif_id: motif&.id,
      location: location,
      organisation_id: organisation&.id,
      duration_in_min: duration_in_min,
      start_at: start_at&.to_s,
      user_id: user&.id,
      max_users_limit: max_users_limit,
      pro_ids: pros&.map(&:id),
    }
  end
end
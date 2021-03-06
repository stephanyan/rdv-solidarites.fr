require "administrate/base_dashboard"

class OrganisationDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    name: Field::String,
    agents: Field::HasMany,
    lieux: Field::HasMany,
    motifs: Field::HasMany,
    horaires: Field::String,
    phone_number: Field::String,
    departement: Field::String,
    human_id: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :name,
    :departement,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :name,
    :horaires,
    :phone_number,
    :agents,
    :lieux,
    :motifs,
    :departement,
    :human_id,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :name,
    :horaires,
    :phone_number,
    :agents,
    :lieux,
    :departement,
    :human_id
  ].freeze

  # Overwrite this method to customize how super admins are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(organisation)
    "Organisation ##{organisation.id} - #{organisation.name}"
  end
end

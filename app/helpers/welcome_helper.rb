module WelcomeHelper
  include SectorisationUtils

  def root_path?
    root_path == request.path
  end

  def sign_up_agent_button
    link_to "Je m'inscris", new_agent_registration_path, class: "btn btn-primary"
  end

  def sign_in_agent_button
    link_to "Se connecter en tant qu'agent", new_agent_session_path, class: "btn btn-outline-white"
  end

  def sign_in_user_button
    link_to "Se connecter", new_user_session_path, class: "btn btn-white"
  end

  def contact_us_button
    mail_to "contact@rdv-solidarites.fr", "Contactez-nous", class: "btn btn-tertiary"
  end

  def urgency_quote
    "En cas de besoin, vous pouvez contacter le <b>#{urgency_number}</b>.".html_safe if urgency_number
  end

  def urgency_number
    return nil unless urgency_number_raw.present?

    human, raw = urgency_number_raw
    link_to human, "tel:#{raw}", class: "urgency-number"
  end

  def urgency_number_raw
    {
      "14" => ["02 31 57 14 14", "+33231571414"],
      "22" => ["02.96.60.86.86", "+33296608686"],
      "55" => ["03.29.80.32.34", "+33329803234"],
      "64" => ["05.59.69.34.11", "+33559693411"],
      "77" => ["01.64.14.77.77", "+33164147777"],
      "78" => ["01 30 836 836", "+33130836836"],
      "80" => ["03.22.71.80.80", "+33322718080"],
      "92" => ["01.55.48.03.30", "+33155480330"],
      "95" => ["01 34 25 30 30", "+33134253030"]
    }[departement_params]
  end

  def departement_params
    (controller_name == "welcome" && params[:departement]) || (params[:search] && params[:search][:departement])
  end

  def sectorisation_hint(zone, organisations, departement)
    return nil if !sectorisation_enabled?(departement) || zone.nil?

    "Sectorisation : Commune #{@zone.city_name} → #{organisations.pluck(:name).join(', ')}"
  end
end

class Enrollment::ApiImpotParticulier < Enrollment
  protected

  def update_validation
    errors[:previous_enrollment_id] << "Vous devez associer cette demande à une demande Franceconnect validée. Aucun changement n'a été sauvegardé." unless previous_enrollment_id.present?
    super
  end

  def sent_validation
    # Organisation
    errors[:siret] << "Vous devez renseigner un SIRET d'organisation valide avant de continuer" unless nom_raison_sociale.present?

    # Description
    errors[:description] << "Vous devez renseigner la description de la démarche avant de continuer" unless description.present?

    # Volumétrie
    errors[:volumetrie_appels_par_minute] << "Vous devez renseigner la limitation d'appels par minute avant de continuer" unless additional_content&.fetch("volumetrie_appels_par_minute", false)&.present?

    # Mise en œuvre
    contact_technique_validation

    # Données
    errors[:rgpd_general_agreement] << "Vous devez attester respecter les principes RGPD avant de continuer" unless additional_content&.fetch("rgpd_general_agreement", false)

    # CGU
    errors[:cgu_approved] << "Vous devez valider les modalités d'utilisation avant de continuer" unless cgu_approved?

    unless user.email_verified
      errors[:base] << "L'accès à votre adresse email n'a pas pu être vérifié. Merci de vous rendre sur #{ENV.fetch("OAUTH_HOST")}/users/verify-email puis de cliquer sur 'Me renvoyer un code de confirmation'"
    end
  end
end

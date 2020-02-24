class ApiParticulierBridge < BridgeService
  def initialize(enrollment)
    @enrollment = enrollment
  end

  def call
    name = "#{@enrollment.nom_raison_sociale} - #{@enrollment.id}"
    email = @enrollment.contacts.find { |contact| contact["id"] == "technique" }["email"]
    scopes = @enrollment[:scopes].reject { |_, v| !v }.keys
    linked_token_manager_id = create_enrollment_in_token_manager(@enrollment.id, name, email, scopes)
    @enrollment.update({linked_token_manager_id: linked_token_manager_id})
  end

  private

  def create_enrollment_in_token_manager(id, name, email, scopes)
    endpoint_label = "espace admin API Particulier"
    url_as_string = "#{ENV.fetch("API_PARTICULIER_HOST")}/admin/api/token"
    body = {
      name: name,
      email: email,
      signup_id: id,
      scopes: scopes,
    }
    api_key = ENV.fetch("API_PARTICULIER_API_KEY")

    response = HTTP
      .auth("Bearer #{api_key}")
      .headers(accept: "application/json")
      .headers("x-api-key" => api_key)
      .post(url_as_string, json: body)

    unless response.status.success?
      raise ApplicationController::BadGateway.new(
        endpoint_label,
        url_as_string,
        response.code,
        response.parse,
      )
    end

    response.parse["_id"]
  rescue HTTP::Error => e
    raise ApplicationController::BadGateway.new(
      endpoint_label,
      url_as_string,
      nil,
      nil,
    ), e.message
  end
end
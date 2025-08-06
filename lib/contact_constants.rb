module ContactConstants
  # Custom attributes that should be hidden from dashboard APIs
  # These attributes contain sensitive information that should only be
  # accessible via widget APIs and webhooks
  SENSITIVE_CUSTOM_ATTRIBUTES = ['auth_token'].freeze
end

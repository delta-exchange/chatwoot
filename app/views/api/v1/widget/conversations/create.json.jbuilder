json.id @conversation.display_id
json.inbox_id @conversation.inbox_id
json.contact_last_seen_at @conversation.contact_last_seen_at.to_i
json.status @conversation.status
json.messages do
  json.array! @conversation.messages do |message|
    json.partial! 'api/v1/models/widget_message', resource: message
  end
end
json.custom_attributes @conversation.custom_attributes
json.contact do
  # Widget should NOT have access to sensitive attributes like auth_token
  json.partial! 'api/v1/models/contact', formats: [:json], resource: @conversation.contact, locals: { include_auth_token: false }
end

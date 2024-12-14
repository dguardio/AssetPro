require 'rails_helper'

RSpec.configure do |config|
  config.openapi_root = Rails.root.join('swagger').to_s

  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Asset Tracking API V1',
        version: 'v1',
        description: 'API for RFID scanners, mobile apps, and ERP integration'
      },
      components: {
        securitySchemes: {
          oauth2: {
            type: :oauth2,
            flows: {
              clientCredentials: {
                tokenUrl: '/oauth/token',
                scopes: {
                  'read': 'Read access',
                  'write': 'Write access',
                  'admin': 'Admin access'
                }
              }
            }
          }
        }
      },
      paths: {},
      servers: [
        {
          url: Rails.env.production? ? 'https://app.getassetpro.com' : 'http://localhost:3000',
          description: 'API Server'
        }
      ]
    }
  }
end 
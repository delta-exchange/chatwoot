# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Chatwoot is an open-source customer support platform with omnichannel capabilities, supporting email, social media (Facebook, Instagram, WhatsApp, Telegram), SMS, and website chat widgets.

## Tech Stack

- **Backend**: Ruby on Rails 7.0.8.4 (Ruby 3.2.2)
- **Frontend**: Vue.js 2.7.0 with Webpack 4.46.0
- **Database**: PostgreSQL (primary), Redis (caching/sessions)
- **Real-time**: ActionCable WebSockets
- **Background Jobs**: Sidekiq
- **Package Managers**: yarn/npm (frontend), Bundler (backend)

## Essential Commands

### Development Setup
```bash
# Install dependencies
bundle install
yarn install

# Database setup
rails db:create
rails db:migrate
rails db:seed

# Start development servers
foreman start -f Procfile.dev
# Or individually:
rails server -p 3000
bin/webpack-dev-server
bundle exec sidekiq

# Alternative with Make commands
make setup       # Install dependencies
make db_setup    # Create, migrate and seed database
make run         # Start with overmind if available
```

### Testing
```bash
# Backend tests
bundle exec rspec                    # Run all RSpec tests
bundle exec rspec spec/models        # Run model tests
bundle exec rspec spec/controllers   # Run controller tests
RAILS_ENV=test rspec path/to/spec.rb # Run specific test file

# Frontend tests
yarn test                            # Run Vue component tests  
yarn test:watch                      # Watch mode for tests
yarn test:coverage                   # Generate frontend coverage

# Coverage
COVERAGE=true bundle exec rspec      # Generate backend coverage
```

### Code Quality
```bash
# Linting
bundle exec rubocop               # Ruby linting
bundle exec rubocop -a             # Auto-fix Ruby issues
yarn eslint                       # Frontend linting
yarn eslint:fix                   # Auto-fix frontend issues
```

### Build & Deployment
```bash
# Frontend build (webpack compilation)
bin/webpack

# Asset precompilation
rails assets:precompile

# Database migrations (production)
rails db:migrate RAILS_ENV=production
```

## Architecture

### Directory Structure
- `app/` - Rails application code
  - `controllers/` - API and web controllers
  - `models/` - ActiveRecord models
  - `services/` - Business logic services
  - `jobs/` - Background job processors
  - `mailers/` - Email handlers
  - `listeners/` - Event listeners (Wisper)
  - `builders/` - Complex object builders
  - `finders/` - Query objects
  - `dispatchers/` - Event dispatchers
- `app/javascript/` - Vue.js frontend applications
  - `dashboard/` - Main agent dashboard
  - `widget/` - Customer-facing chat widget
  - `portal/` - Knowledge base portal
  - `survey/` - Customer satisfaction surveys
  - `shared/` - Shared components and utilities
- `enterprise/` - Premium features (separate license)
- `lib/` - Ruby libraries and integrations
- `spec/` - RSpec test suite

### Key Design Patterns

1. **Multi-tenancy**: Account-based isolation with `Current.account` context
2. **Event-driven**: Wisper pub/sub for decoupled communication between services
3. **Service Objects**: Business logic encapsulated in `app/services/`
4. **API-first**: RESTful JSON APIs with Jbuilder views
5. **Channel Abstraction**: Unified interface for multiple messaging channels

### Database Schema
- **Core Models**: Account, User, Conversation, Message, Contact
- **Channel Models**: Channel::FacebookPage, Channel::WebWidget, Channel::Email, etc.
- **Team Models**: Team, TeamMember for agent organization
- **Automation**: AutomationRule, Macro for workflow automation

### API Structure
- `/api/v1/` - Public API endpoints
- `/public/api/v1/` - Widget/portal endpoints (no auth)
- `/super_admin/` - Admin panel endpoints
- Authentication: Devise with JWT tokens

### Frontend Architecture
- **State Management**: Vuex 2.1.1 stores for each app
- **API Client**: Axios with interceptors
- **Component Library**: Custom UI components in `shared/`
- **Routing**: Vue Router 3.5.2 with lazy loading
- **Build System**: Webpack 4 with Rails Webpacker
- **CSS Framework**: Tailwind CSS 3.3.2

## Environment Configuration

Key environment variables:
- `DATABASE_URL` - PostgreSQL connection
- `REDIS_URL` - Redis connection
- `FRONTEND_URL` - Public-facing URL
- `RAILS_ENV` - Environment (development/production)
- `SECRET_KEY_BASE` - Rails secret key
- `ACTIVE_STORAGE_SERVICE` - File storage backend

## Common Development Tasks

### Adding a New Channel
1. Create channel model in `app/models/channel/`
2. Add builder in `app/builders/`
3. Create webhook controller if needed
4. Add frontend components in `dashboard/routes/dashboard/settings/inbox/`

### Creating API Endpoints
1. Add route in `config/routes.rb`
2. Create controller in `app/controllers/api/v1/`
3. Add Jbuilder view in `app/views/api/v1/`
4. Write RSpec tests in `spec/controllers/`

### Working with Background Jobs
1. Create job in `app/jobs/`
2. Use `perform_later` for async execution
3. Monitor in Sidekiq dashboard at `/sidekiq`

## Important Notes

- The `develop` branch is the main development branch (not `main` or `master`)
- Enterprise features require separate license and are in `enterprise/` directory
  - Premium features include: disable_branding, audit_logs, response_bot, sla
- Always run tests before committing: `bundle exec rspec` and `yarn test`
- Use service objects for complex business logic rather than fat models/controllers
- Frontend changes require running `bin/webpack-dev-server` for hot module replacement
- Background jobs must be idempotent as Sidekiq may retry failed jobs
- Node version: 20.x, Yarn version: 1.22.x, Ruby version: 3.2.2
- For legacy OpenSSL support in development: `export NODE_OPTIONS=--openssl-legacy-provider`
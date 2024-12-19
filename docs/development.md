# Development Setup Guide

## System Requirements
- Ruby 3.2+
- PostgreSQL 14+
- Node.js 18+
- Redis (for background jobs)

## Initial Setup

### 1. Dependencies 
bash
Install Ruby dependencies
bundle install
Install Node dependencies
yarn install


### 2. Database Setup
bash
rails db:setup


### 3. Environment Configuration
Copy `.env.example` to `.env` and configure:
- Database credentials
- Redis URL
- OAuth settings
- RFID scanner settings

### 4. Running Tests
bash
Run all tests
rspec
Run system tests
rspec spec/system


### 5. Development Server
bash
bin/


## Development Workflow
1. Create feature branch
2. Write tests
3. Implement feature
4. Run test suite
5. Submit pull request

## Code Style
- Follow Ruby Style Guide
- Use RuboCop for linting
- Write meaningful commit messages

## Testing
- RSpec for unit/integration tests
- System tests for UI flows
- Factory Bot for test data
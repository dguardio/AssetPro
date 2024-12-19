# Quick Start Guide

## Prerequisites
- Ruby 3.2+
- PostgreSQL 14+
- Node.js 18+
- RFID Scanner (optional for testing)

## 5-Minute Setup

1. **Clone & Install** 
bash
git clone https://github.com/yourusername/asset-management
cd asset-management
bundle install
yarn install


2. **Configure Environment**
bash
cp .env.example .env
Edit .env with your database credentials


3. **Setup Database**
bash
rails db:create db:migrate db:seed


4. **Start Server**
bash
bin/dev


5. **Access Application**
- Visit http://localhost:3000
- Login with demo credentials:
  - Email: admin@example.com
  - Password: password123

#!/bin/bash

# AutomateAI SaaS Setup Script
# This script automates the initial setup process

set -e

echo "🚀 AutomateAI SaaS Setup Script"
echo "================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed${NC}"
    echo "Please install Node.js 20+ from https://nodejs.org"
    exit 1
fi

# Check Node.js version
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 20 ]; then
    echo -e "${RED}❌ Node.js version must be 20 or higher${NC}"
    echo "Current version: $(node -v)"
    exit 1
fi

echo -e "${GREEN}✅ Node.js $(node -v) detected${NC}"

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ npm is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ npm $(npm -v) detected${NC}"
echo ""

# Install dependencies
echo "📦 Installing dependencies..."
npm install

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Dependencies installed successfully${NC}"
else
    echo -e "${RED}❌ Failed to install dependencies${NC}"
    exit 1
fi

echo ""

# Check if .env.local exists
if [ ! -f .env.local ]; then
    echo "📝 Creating .env.local file..."
    cp .env.example .env.local
    echo -e "${YELLOW}⚠️  Please update .env.local with your actual credentials${NC}"
    echo ""
    echo "Required credentials:"
    echo "  - Supabase URL and keys"
    echo "  - Clerk publishable and secret keys"
    echo "  - Stripe keys"
    echo "  - AI API keys (Gemini, Groq, etc.)"
    echo ""
    read -p "Press Enter to continue after updating .env.local..."
else
    echo -e "${GREEN}✅ .env.local already exists${NC}"
fi

echo ""

# Check if DATABASE_URL is set
if ! grep -q "DATABASE_URL=" .env.local || grep -q "your-project-ref" .env.local; then
    echo -e "${YELLOW}⚠️  DATABASE_URL not configured${NC}"
    echo "Please set up Supabase and update DATABASE_URL in .env.local"
    read -p "Press Enter to continue..."
fi

echo ""

# Generate Prisma client
echo "🔧 Generating Prisma client..."
npx prisma generate

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Prisma client generated${NC}"
else
    echo -e "${RED}❌ Failed to generate Prisma client${NC}"
    exit 1
fi

echo ""

# Ask if user wants to run migrations
read -p "Do you want to run database migrations? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🗄️  Running database migrations..."
    npx prisma migrate dev --name init
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Database migrations completed${NC}"
    else
        echo -e "${RED}❌ Failed to run migrations${NC}"
        echo "Please check your DATABASE_URL and try again"
    fi
fi

echo ""

# Ask if user wants to seed database
read -p "Do you want to seed the database with sample data? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🌱 Seeding database..."
    npm run db:seed
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Database seeded successfully${NC}"
    else
        echo -e "${YELLOW}⚠️  Failed to seed database (this is optional)${NC}"
    fi
fi

echo ""
echo "================================"
echo -e "${GREEN}✅ Setup completed successfully!${NC}"
echo ""
echo "Next steps:"
echo "  1. Update .env.local with your credentials"
echo "  2. Run 'npm run dev' to start development server"
echo "  3. Open http://localhost:3000 in your browser"
echo ""
echo "Documentation:"
echo "  - README.md - Project overview"
echo "  - docs/MASTER_PROMPT.md - Complete build guide"
echo "  - docs/DATABASE.md - Database schema"
echo "  - docs/DEPLOYMENT.md - Deployment guide"
echo "  - docs/AI_INTEGRATION.md - AI integration guide"
echo ""
echo "Need help? Open an issue on GitHub:"
echo "  https://github.com/itskiranbabu/automate-ai-saas/issues"
echo ""
echo "Happy coding! 🚀"

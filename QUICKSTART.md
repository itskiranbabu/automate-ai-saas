# 🎯 QUICK START GUIDE

Get AutomateAI SaaS up and running in 30 minutes.

## Prerequisites Checklist

Before starting, ensure you have:

- [ ] **Node.js 20+** installed ([download](https://nodejs.org))
- [ ] **Git** installed
- [ ] **Supabase account** ([sign up](https://supabase.com))
- [ ] **Clerk account** ([sign up](https://clerk.com))
- [ ] **Stripe account** ([sign up](https://stripe.com))
- [ ] **Google Gemini API key** ([get key](https://makersuite.google.com/app/apikey))
- [ ] **Code editor** (VS Code recommended)

## Step 1: Clone Repository (2 minutes)

```bash
# Clone the repository
git clone https://github.com/itskiranbabu/automate-ai-saas.git

# Navigate to project directory
cd automate-ai-saas

# Install dependencies
npm install
```

## Step 2: Set Up Supabase (5 minutes)

### 2.1 Create Project

1. Go to [supabase.com/dashboard](https://supabase.com/dashboard)
2. Click **"New Project"**
3. Fill in:
   - **Name**: `automate-ai-saas`
   - **Database Password**: (generate strong password)
   - **Region**: Choose closest to you
4. Wait ~2 minutes for project creation

### 2.2 Get Credentials

1. Go to **Settings** → **API**
2. Copy:
   - **Project URL**
   - **anon public key**
   - **service_role key** (keep secret!)

3. Go to **Settings** → **Database**
4. Copy **Connection String** (URI format)

### 2.3 Enable Extensions

1. Go to **SQL Editor**
2. Run this SQL:

```sql
-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable vector operations (for AI)
CREATE EXTENSION IF NOT EXISTS vector;

-- Enable full-text search
CREATE EXTENSION IF NOT EXISTS pg_trgm;
```

## Step 3: Set Up Clerk (5 minutes)

### 3.1 Create Application

1. Go to [dashboard.clerk.com](https://dashboard.clerk.com)
2. Click **"Add Application"**
3. Configure:
   - **Name**: AutomateAI
   - **Sign-in options**: Email, Google, GitHub
   - **Sign-up mode**: Public

### 3.2 Get API Keys

1. Go to **API Keys**
2. Copy:
   - **Publishable Key** (starts with `pk_test_`)
   - **Secret Key** (starts with `sk_test_`)

### 3.3 Configure OAuth (Optional)

**Google:**
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create OAuth 2.0 Client ID
3. Add to Clerk

**GitHub:**
1. Go to [GitHub Settings](https://github.com/settings/developers)
2. Create OAuth App
3. Add to Clerk

## Step 4: Set Up Stripe (5 minutes)

### 4.1 Get API Keys

1. Go to [dashboard.stripe.com/apikeys](https://dashboard.stripe.com/apikeys)
2. Copy:
   - **Publishable Key** (starts with `pk_test_`)
   - **Secret Key** (starts with `sk_test_`)

### 4.2 Create Products

Run these commands in terminal:

```bash
# Install Stripe CLI
brew install stripe/stripe-cli/stripe
# or download from https://stripe.com/docs/stripe-cli

# Login
stripe login

# Create Free Plan
stripe products create --name="Free Plan" --description="5 workflows, 1000 executions/month"
# Copy product ID (prod_xxx)

stripe prices create --product=prod_xxx --unit-amount=0 --currency=usd --recurring[interval]=month
# Copy price ID (price_xxx)

# Create Pro Plan
stripe products create --name="Pro Plan" --description="50 workflows, 50000 executions/month"
stripe prices create --product=prod_xxx --unit-amount=2900 --currency=usd --recurring[interval]=month

# Create Enterprise Plan
stripe products create --name="Enterprise Plan" --description="Unlimited workflows and executions"
stripe prices create --product=prod_xxx --unit-amount=29900 --currency=usd --recurring[interval]=month
```

## Step 5: Get AI API Keys (3 minutes)

### Google Gemini (Required)

1. Go to [makersuite.google.com/app/apikey](https://makersuite.google.com/app/apikey)
2. Click **"Create API Key"**
3. Copy the key

### Groq (Optional but Recommended)

1. Go to [console.groq.com/keys](https://console.groq.com/keys)
2. Create new API key
3. Copy the key

## Step 6: Configure Environment (5 minutes)

### 6.1 Create .env.local

```bash
# Copy example file
cp .env.example .env.local
```

### 6.2 Update .env.local

Open `.env.local` and update these values:

```env
# App
NEXT_PUBLIC_APP_NAME="AutomateAI"
NEXT_PUBLIC_APP_URL="http://localhost:3000"

# Supabase (from Step 2)
NEXT_PUBLIC_SUPABASE_URL="https://xxxxx.supabase.co"
NEXT_PUBLIC_SUPABASE_ANON_KEY="eyJhbGc..."
SUPABASE_SERVICE_ROLE_KEY="eyJhbGc..."
DATABASE_URL="postgresql://postgres:[password]@db.xxxxx.supabase.co:5432/postgres"

# Clerk (from Step 3)
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY="pk_test_..."
CLERK_SECRET_KEY="sk_test_..."

# Stripe (from Step 4)
STRIPE_SECRET_KEY="sk_test_..."
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY="pk_test_..."
STRIPE_PRICE_ID_FREE="price_xxx"
STRIPE_PRICE_ID_PRO="price_xxx"
STRIPE_PRICE_ID_ENTERPRISE="price_xxx"

# AI (from Step 5)
GOOGLE_GEMINI_API_KEY="your-gemini-key"
GROQ_API_KEY="gsk_..." # optional
```

## Step 7: Set Up Database (3 minutes)

```bash
# Generate Prisma client
npx prisma generate

# Run migrations
npx prisma migrate dev --name init

# Seed database (optional)
npm run db:seed
```

## Step 8: Start Development Server (1 minute)

```bash
# Start the app
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

## Step 9: Test Everything (5 minutes)

### 9.1 Test Authentication

1. Go to http://localhost:3000
2. Click **"Sign Up"**
3. Create account with email
4. Verify you're redirected to dashboard

### 9.2 Test AI Chat

1. Go to dashboard
2. Find AI chat interface
3. Send a message
4. Verify AI responds

### 9.3 Test Workflow Creation

1. Go to **Workflows**
2. Click **"New Workflow"**
3. Add nodes
4. Save workflow

## Troubleshooting

### Issue: "Cannot connect to database"

**Solution:**
- Check DATABASE_URL is correct
- Ensure Supabase project is active
- Verify password in connection string

### Issue: "Clerk authentication not working"

**Solution:**
- Check Clerk keys are correct
- Verify NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY starts with `pk_test_`
- Check CLERK_SECRET_KEY starts with `sk_test_`

### Issue: "Stripe webhook not receiving events"

**Solution:**
- Use Stripe CLI for local testing:
  ```bash
  stripe listen --forward-to localhost:3000/api/webhooks/stripe
  ```

### Issue: "AI not responding"

**Solution:**
- Check GOOGLE_GEMINI_API_KEY is set
- Verify API key is valid
- Check console for errors

## Next Steps

### For Development

1. **Read Documentation**
   - [Master Prompt](docs/MASTER_PROMPT.md) - Complete build guide
   - [Database Schema](docs/DATABASE.md) - Database structure
   - [AI Integration](docs/AI_INTEGRATION.md) - AI setup

2. **Customize**
   - Update branding in `app/layout.tsx`
   - Modify colors in `tailwind.config.ts`
   - Add your logo to `public/`

3. **Build Features**
   - Follow [Master Prompt](docs/MASTER_PROMPT.md)
   - Use Cursor/Windsurf AI for code generation
   - Test frequently

### For Deployment

1. **Prepare for Production**
   - Review [Deployment Guide](docs/DEPLOYMENT.md)
   - Set up production accounts (Clerk, Stripe)
   - Configure custom domain

2. **Deploy to Vercel**
   ```bash
   vercel --prod
   ```

3. **Post-Deployment**
   - Update webhook URLs
   - Test payment flow
   - Monitor errors

## Resources

- **Documentation**: `/docs` folder
- **GitHub**: [github.com/itskiranbabu/automate-ai-saas](https://github.com/itskiranbabu/automate-ai-saas)
- **Issues**: [Report bugs](https://github.com/itskiranbabu/automate-ai-saas/issues)

## Getting Help

- 📖 Check [documentation](docs/)
- 🐛 [Open an issue](https://github.com/itskiranbabu/automate-ai-saas/issues)
- 💬 Join Discord (coming soon)
- 📧 Email: support@automateai.com

---

**Congratulations! You're ready to build! 🚀**

Total setup time: ~30 minutes

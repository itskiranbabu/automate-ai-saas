# 🚀 Deployment Guide

Complete guide to deploying AutomateAI SaaS Platform to production using Vercel and Supabase.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Supabase Setup](#supabase-setup)
- [Clerk Setup](#clerk-setup)
- [Stripe Setup](#stripe-setup)
- [Vercel Deployment](#vercel-deployment)
- [Environment Variables](#environment-variables)
- [Post-Deployment](#post-deployment)
- [Monitoring](#monitoring)
- [Troubleshooting](#troubleshooting)

## Prerequisites

Before deploying, ensure you have:

- ✅ GitHub account with repository access
- ✅ Vercel account ([vercel.com](https://vercel.com))
- ✅ Supabase account ([supabase.com](https://supabase.com))
- ✅ Clerk account ([clerk.com](https://clerk.com))
- ✅ Stripe account ([stripe.com](https://stripe.com))
- ✅ Domain name (optional, Vercel provides free subdomain)
- ✅ AI API keys (Gemini, Groq, etc.)

## Supabase Setup

### 1. Create Supabase Project

1. Go to [supabase.com/dashboard](https://supabase.com/dashboard)
2. Click **"New Project"**
3. Fill in project details:
   - **Name**: `automate-ai-saas-prod`
   - **Database Password**: Generate strong password
   - **Region**: Choose closest to your users
   - **Pricing Plan**: Start with Free, upgrade as needed

4. Wait for project to be created (~2 minutes)

### 2. Get Database Credentials

1. Go to **Settings** → **Database**
2. Copy the following:
   - **Connection String** (URI format)
   - **Project URL**
   - **Anon Key** (public)
   - **Service Role Key** (secret)

```env
NEXT_PUBLIC_SUPABASE_URL="https://xxxxx.supabase.co"
NEXT_PUBLIC_SUPABASE_ANON_KEY="eyJhbGc..."
SUPABASE_SERVICE_ROLE_KEY="eyJhbGc..."
DATABASE_URL="postgresql://postgres:[password]@db.xxxxx.supabase.co:5432/postgres"
```

### 3. Enable Required Extensions

Go to **Database** → **Extensions** and enable:

```sql
-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable vector operations (for AI embeddings)
CREATE EXTENSION IF NOT EXISTS vector;

-- Enable full-text search
CREATE EXTENSION IF NOT EXISTS pg_trgm;
```

Or run in SQL Editor:

1. Go to **SQL Editor**
2. Click **"New Query"**
3. Paste the SQL above
4. Click **"Run"**

### 4. Configure Storage

1. Go to **Storage** → **Create Bucket**
2. Create buckets:
   - `workflows` (private)
   - `documents` (private)
   - `avatars` (public)

3. Set up storage policies:

```sql
-- Allow authenticated users to upload to their folder
CREATE POLICY "Users can upload to own folder"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'workflows' AND (storage.foldername(name))[1] = auth.uid()::text);

-- Allow users to read their own files
CREATE POLICY "Users can read own files"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'workflows' AND (storage.foldername(name))[1] = auth.uid()::text);
```

### 5. Set Up Database Backups

1. Go to **Settings** → **Database**
2. Enable **Point-in-Time Recovery** (Pro plan)
3. Configure backup schedule

## Clerk Setup

### 1. Create Clerk Application

1. Go to [dashboard.clerk.com](https://dashboard.clerk.com)
2. Click **"Add Application"**
3. Configure:
   - **Name**: AutomateAI
   - **Sign-in options**: Email, Google, GitHub
   - **Sign-up mode**: Public

### 2. Configure OAuth Providers

#### Google OAuth

1. Go to **User & Authentication** → **Social Connections**
2. Enable **Google**
3. Add OAuth credentials:
   - Go to [Google Cloud Console](https://console.cloud.google.com)
   - Create OAuth 2.0 Client ID
   - Add authorized redirect URI: `https://your-clerk-domain.clerk.accounts.dev/v1/oauth_callback`

#### GitHub OAuth

1. Enable **GitHub** in Clerk
2. Go to [GitHub Settings](https://github.com/settings/developers)
3. Create OAuth App
4. Add callback URL from Clerk

### 3. Get Clerk Keys

1. Go to **API Keys**
2. Copy:
   - **Publishable Key** (starts with `pk_`)
   - **Secret Key** (starts with `sk_`)

```env
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY="pk_test_..."
CLERK_SECRET_KEY="sk_test_..."
```

### 4. Configure Webhooks

1. Go to **Webhooks** → **Add Endpoint**
2. Add endpoint: `https://your-domain.com/api/webhooks/clerk`
3. Subscribe to events:
   - `user.created`
   - `user.updated`
   - `user.deleted`
4. Copy **Signing Secret**

```env
CLERK_WEBHOOK_SECRET="whsec_..."
```

### 5. Customize Appearance

1. Go to **Customization** → **Theme**
2. Match your brand colors
3. Upload logo
4. Customize sign-in/sign-up pages

## Stripe Setup

### 1. Create Stripe Account

1. Go to [stripe.com](https://stripe.com)
2. Create account or sign in
3. Complete business verification

### 2. Get API Keys

1. Go to **Developers** → **API Keys**
2. Copy:
   - **Publishable Key** (starts with `pk_`)
   - **Secret Key** (starts with `sk_`)

```env
STRIPE_SECRET_KEY="sk_test_..."
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY="pk_test_..."
```

### 3. Create Products & Prices

#### Free Tier
```bash
# Create product
stripe products create \
  --name="Free Plan" \
  --description="5 workflows, 1000 executions/month"

# Create price (free)
stripe prices create \
  --product=prod_xxx \
  --unit-amount=0 \
  --currency=usd \
  --recurring[interval]=month
```

#### Pro Tier
```bash
# Create product
stripe products create \
  --name="Pro Plan" \
  --description="50 workflows, 50000 executions/month"

# Create price ($29/month)
stripe prices create \
  --product=prod_xxx \
  --unit-amount=2900 \
  --currency=usd \
  --recurring[interval]=month
```

#### Enterprise Tier
```bash
# Create product
stripe products create \
  --name="Enterprise Plan" \
  --description="Unlimited workflows and executions"

# Create price ($299/month)
stripe prices create \
  --product=prod_xxx \
  --unit-amount=29900 \
  --currency=usd \
  --recurring[interval]=month
```

Save the price IDs:

```env
STRIPE_PRICE_ID_FREE="price_xxx"
STRIPE_PRICE_ID_PRO="price_xxx"
STRIPE_PRICE_ID_ENTERPRISE="price_xxx"
```

### 4. Configure Webhooks

1. Go to **Developers** → **Webhooks**
2. Click **"Add Endpoint"**
3. Add endpoint: `https://your-domain.com/api/webhooks/stripe`
4. Select events:
   - `checkout.session.completed`
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`

5. Copy **Signing Secret**

```env
STRIPE_WEBHOOK_SECRET="whsec_..."
```

### 5. Test Mode

Keep in **Test Mode** until ready for production:
- Use test cards: `4242 4242 4242 4242`
- Test webhooks with Stripe CLI

## Vercel Deployment

### Method 1: Deploy Button (Easiest)

1. Click the deploy button in README
2. Connect GitHub repository
3. Configure environment variables
4. Deploy

### Method 2: Vercel CLI

```bash
# Install Vercel CLI
npm i -g vercel

# Login
vercel login

# Deploy to production
vercel --prod
```

### Method 3: GitHub Integration

1. Go to [vercel.com/new](https://vercel.com/new)
2. Import Git Repository
3. Select `itskiranbabu/automate-ai-saas`
4. Configure project:
   - **Framework Preset**: Next.js
   - **Root Directory**: `./`
   - **Build Command**: `npm run build`
   - **Output Directory**: `.next`

5. Add environment variables (see below)
6. Click **"Deploy"**

## Environment Variables

### Required Variables

Add these in Vercel dashboard (**Settings** → **Environment Variables**):

```env
# App
NEXT_PUBLIC_APP_NAME="AutomateAI"
NEXT_PUBLIC_APP_URL="https://your-domain.com"
NODE_ENV="production"

# Supabase
NEXT_PUBLIC_SUPABASE_URL="https://xxxxx.supabase.co"
NEXT_PUBLIC_SUPABASE_ANON_KEY="eyJhbGc..."
SUPABASE_SERVICE_ROLE_KEY="eyJhbGc..."
DATABASE_URL="postgresql://postgres:[password]@db.xxxxx.supabase.co:5432/postgres"

# Clerk
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY="pk_live_..."
CLERK_SECRET_KEY="sk_live_..."
CLERK_WEBHOOK_SECRET="whsec_..."
NEXT_PUBLIC_CLERK_SIGN_IN_URL="/sign-in"
NEXT_PUBLIC_CLERK_SIGN_UP_URL="/sign-up"
NEXT_PUBLIC_CLERK_AFTER_SIGN_IN_URL="/dashboard"
NEXT_PUBLIC_CLERK_AFTER_SIGN_UP_URL="/onboarding"

# Stripe
STRIPE_SECRET_KEY="sk_live_..."
STRIPE_WEBHOOK_SECRET="whsec_..."
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY="pk_live_..."
STRIPE_PRICE_ID_FREE="price_..."
STRIPE_PRICE_ID_PRO="price_..."
STRIPE_PRICE_ID_ENTERPRISE="price_..."

# AI Services
GOOGLE_GEMINI_API_KEY="your-key"
GROQ_API_KEY="gsk_..."
OPENAI_API_KEY="sk-..."
ANTHROPIC_API_KEY="sk-ant-..."

# Analytics
NEXT_PUBLIC_POSTHOG_KEY="phc_..."
NEXT_PUBLIC_POSTHOG_HOST="https://app.posthog.com"
SENTRY_DSN="https://...@sentry.io/..."

# Email
RESEND_API_KEY="re_..."
EMAIL_FROM="noreply@yourdomain.com"
```

### Variable Scopes

Set appropriate scopes for each variable:
- **Production**: Live environment
- **Preview**: Pull request previews
- **Development**: Local development

## Post-Deployment

### 1. Run Database Migrations

```bash
# Connect to production database
DATABASE_URL="your-production-url" npx prisma migrate deploy

# Or use Vercel CLI
vercel env pull .env.production
npm run db:migrate:deploy
```

### 2. Seed Initial Data

```bash
# Seed AI models and templates
npm run db:seed
```

### 3. Configure Custom Domain

1. Go to Vercel project **Settings** → **Domains**
2. Add your domain: `automateai.com`
3. Configure DNS:

```
Type: A
Name: @
Value: 76.76.21.21

Type: CNAME
Name: www
Value: cname.vercel-dns.com
```

4. Wait for DNS propagation (~24 hours)
5. Enable HTTPS (automatic with Vercel)

### 4. Update Webhook URLs

Update webhook URLs in:
- **Clerk**: `https://automateai.com/api/webhooks/clerk`
- **Stripe**: `https://automateai.com/api/webhooks/stripe`

### 5. Test Payment Flow

1. Create test account
2. Upgrade to Pro plan
3. Verify Stripe webhook received
4. Check database subscription updated
5. Test workflow limits

### 6. Enable Production Mode

#### Clerk
1. Go to **Settings** → **General**
2. Switch to **Production**
3. Update API keys in Vercel

#### Stripe
1. Toggle **View test data** off
2. Use live API keys
3. Update webhook endpoints

## Monitoring

### Vercel Analytics

1. Go to **Analytics** tab
2. Enable **Web Analytics**
3. Monitor:
   - Page views
   - Unique visitors
   - Top pages
   - Performance metrics

### Sentry Error Tracking

1. Create Sentry project
2. Add DSN to environment variables
3. Monitor errors in real-time

```typescript
// sentry.config.ts
import * as Sentry from '@sentry/nextjs';

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  tracesSampleRate: 1.0,
  environment: process.env.NODE_ENV,
});
```

### PostHog Analytics

1. Create PostHog project
2. Add API key to environment variables
3. Track user events

```typescript
// lib/analytics.ts
import posthog from 'posthog-js';

posthog.init(process.env.NEXT_PUBLIC_POSTHOG_KEY!, {
  api_host: 'https://app.posthog.com',
});

// Track events
posthog.capture('workflow_created', {
  workflowId: 'xxx',
  userId: 'xxx',
});
```

### Supabase Monitoring

1. Go to Supabase **Reports**
2. Monitor:
   - Database size
   - API requests
   - Storage usage
   - Active connections

### Uptime Monitoring

Use services like:
- [UptimeRobot](https://uptimerobot.com)
- [Pingdom](https://www.pingdom.com)
- [Better Uptime](https://betteruptime.com)

## Troubleshooting

### Build Failures

**Issue**: Build fails on Vercel

```bash
# Check build logs
vercel logs

# Test build locally
npm run build

# Clear cache and rebuild
vercel --force
```

**Common causes**:
- Missing environment variables
- TypeScript errors
- Dependency issues

### Database Connection Issues

**Issue**: Cannot connect to Supabase

```bash
# Test connection
psql $DATABASE_URL

# Check connection string format
postgresql://postgres:[password]@db.[project-ref].supabase.co:5432/postgres
```

**Solutions**:
- Verify DATABASE_URL is correct
- Check Supabase project is active
- Ensure IP is not blocked

### Webhook Issues

**Issue**: Webhooks not received

**Stripe**:
```bash
# Test webhooks locally
stripe listen --forward-to localhost:3000/api/webhooks/stripe

# Verify webhook signature
stripe webhooks verify <payload> <signature> <secret>
```

**Clerk**:
- Check webhook URL is correct
- Verify signing secret
- Check webhook logs in Clerk dashboard

### Performance Issues

**Issue**: Slow page loads

**Solutions**:
1. Enable Vercel Edge Functions
2. Add Redis caching
3. Optimize database queries
4. Use CDN for static assets
5. Enable image optimization

```typescript
// next.config.js
module.exports = {
  images: {
    domains: ['supabase.co'],
    formats: ['image/avif', 'image/webp'],
  },
  experimental: {
    optimizeCss: true,
  },
};
```

## Rollback Strategy

### Vercel Rollback

1. Go to **Deployments**
2. Find previous working deployment
3. Click **"..."** → **"Promote to Production"**

### Database Rollback

```bash
# Rollback last migration
npx prisma migrate resolve --rolled-back <migration-name>

# Restore from backup
psql $DATABASE_URL < backup.sql
```

## Security Checklist

- [ ] All environment variables are set
- [ ] HTTPS is enabled
- [ ] Webhook secrets are configured
- [ ] API keys are not exposed in client code
- [ ] Rate limiting is enabled
- [ ] CORS is properly configured
- [ ] Database RLS policies are active
- [ ] Error messages don't leak sensitive info
- [ ] Dependencies are up to date
- [ ] Security headers are configured

## Performance Checklist

- [ ] Images are optimized
- [ ] Code is minified
- [ ] Gzip compression enabled
- [ ] CDN is configured
- [ ] Database indexes are created
- [ ] API responses are cached
- [ ] Lazy loading is implemented
- [ ] Bundle size is optimized

## Launch Checklist

- [ ] All features tested in production
- [ ] Payment flow works end-to-end
- [ ] Email notifications working
- [ ] Analytics tracking correctly
- [ ] Error monitoring active
- [ ] Backup strategy in place
- [ ] Documentation updated
- [ ] Support channels ready
- [ ] Marketing site live
- [ ] Social media accounts created

## Resources

- [Vercel Documentation](https://vercel.com/docs)
- [Supabase Documentation](https://supabase.com/docs)
- [Clerk Documentation](https://clerk.com/docs)
- [Stripe Documentation](https://stripe.com/docs)
- [Next.js Deployment](https://nextjs.org/docs/deployment)

---

**Need help?** Open an issue on [GitHub](https://github.com/itskiranbabu/automate-ai-saas/issues)

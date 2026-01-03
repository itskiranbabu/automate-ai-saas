# 🚀 AutomateAI SaaS Platform

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/itskiranbabu/automate-ai-saas)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Next.js](https://img.shields.io/badge/Next.js-14-black)](https://nextjs.org/)
[![Supabase](https://img.shields.io/badge/Supabase-Database-green)](https://supabase.com/)

> **Production-ready AI Automation SaaS Platform** combining n8n's workflow automation engine with modern SaaS infrastructure. Build powerful AI workflows with 400+ integrations, native AI capabilities (Gemini, Groq), and complete monetization features.

## 🎯 **What You Get**

- ✅ **Complete SaaS Infrastructure** - Auth, billing, subscriptions, user management
- ✅ **AI Workflow Automation** - Visual workflow builder with 400+ integrations
- ✅ **Multi-AI Support** - Gemini AI, Groq, and open-source models
- ✅ **Production Ready** - Deployed on Vercel + Supabase
- ✅ **Monetization Built-in** - Stripe integration with subscription tiers
- ✅ **Modern Stack** - Next.js 14, TypeScript, Tailwind CSS, shadcn/ui
- ✅ **MCP Integration** - Model Context Protocol for AI agents
- ✅ **Clerk Authentication** - Secure, scalable auth with OAuth providers

## 📋 **Table of Contents**

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Environment Setup](#environment-setup)
- [Database Setup](#database-setup)
- [Deployment](#deployment)
- [Development](#development)
- [API Documentation](#api-documentation)
- [Contributing](#contributing)
- [License](#license)

## ✨ **Features**

### **Core Features**
- 🔐 **Authentication** - Clerk with OAuth (Google, GitHub, Email)
- 💳 **Payments** - Stripe subscriptions with webhook handling
- 🤖 **AI Workflows** - Visual builder for automation workflows
- 🧠 **Multi-AI Models** - Gemini, Groq, OpenAI, Claude support
- 📊 **Analytics** - PostHog integration for user tracking
- 🔔 **Notifications** - Real-time updates and alerts
- 👥 **Team Collaboration** - Share workflows with team members
- 📱 **Responsive UI** - Mobile-first design with Tailwind CSS

### **AI Capabilities**
- 🎨 **AI Content Generation** - Blog posts, social media, emails
- 💬 **AI Chatbots** - Customer support automation
- 📄 **Document Processing** - RAG (Retrieval Augmented Generation)
- 🔍 **Smart Search** - Vector-based semantic search
- 🎯 **AI Agents** - Autonomous task execution
- 🌐 **Multi-Language** - Support for 50+ languages

### **Workflow Features**
- 🔄 **400+ Integrations** - Connect any app or service
- ⚡ **Real-time Execution** - Instant workflow triggers
- 📈 **Scalable** - Handle millions of executions
- 🛡️ **Error Handling** - Retry logic and fallbacks
- 📊 **Monitoring** - Execution logs and analytics
- 🎨 **Templates** - 100+ pre-built workflow templates

## 🛠️ **Tech Stack**

### **Frontend**
- **Framework**: Next.js 14 (App Router)
- **Language**: TypeScript
- **Styling**: Tailwind CSS + shadcn/ui
- **State Management**: Zustand
- **Forms**: React Hook Form + Zod
- **API Client**: TanStack Query

### **Backend**
- **Runtime**: Node.js 20+
- **API**: Next.js API Routes + tRPC
- **Database**: Supabase (PostgreSQL)
- **ORM**: Prisma
- **Authentication**: Clerk
- **Payments**: Stripe
- **File Storage**: Supabase Storage

### **AI & Automation**
- **Workflow Engine**: n8n (modified)
- **AI Models**: 
  - Google Gemini (gemini-pro, gemini-1.5-flash)
  - Groq (llama3-70b, mixtral-8x7b)
  - OpenAI (gpt-4, gpt-3.5-turbo)
  - Anthropic Claude (claude-3-opus)
- **Vector DB**: Supabase pgvector
- **MCP**: Model Context Protocol integration
- **Queue**: Supabase Realtime + Edge Functions

### **DevOps**
- **Hosting**: Vercel (Frontend + API)
- **Database**: Supabase (PostgreSQL + Storage)
- **CI/CD**: GitHub Actions
- **Monitoring**: Sentry + PostHog
- **Analytics**: Vercel Analytics

## 🚀 **Quick Start**

### **Prerequisites**

```bash
# Required
- Node.js 20+ 
- npm/yarn/pnpm
- Git
- Supabase account
- Clerk account
- Stripe account (for payments)
- Vercel account (for deployment)

# Optional
- Gemini API key
- Groq API key
- OpenAI API key
```

### **Installation**

```bash
# 1. Clone the repository
git clone https://github.com/itskiranbabu/automate-ai-saas.git
cd automate-ai-saas

# 2. Install dependencies
npm install

# 3. Copy environment variables
cp .env.example .env.local

# 4. Set up Supabase
npm run db:setup

# 5. Run database migrations
npm run db:migrate

# 6. Seed the database (optional)
npm run db:seed

# 7. Start development server
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

## 📁 **Project Structure**

```
automate-ai-saas/
├── app/                          # Next.js 14 App Router
│   ├── (auth)/                   # Auth pages (sign-in, sign-up)
│   ├── (dashboard)/              # Protected dashboard routes
│   │   ├── workflows/            # Workflow management
│   │   ├── templates/            # Template marketplace
│   │   ├── settings/             # User settings
│   │   └── billing/              # Subscription management
│   ├── api/                      # API routes
│   │   ├── webhooks/             # Stripe webhooks
│   │   ├── workflows/            # Workflow CRUD
│   │   └── ai/                   # AI endpoints
│   └── layout.tsx                # Root layout
├── components/                   # React components
│   ├── ui/                       # shadcn/ui components
│   ├── workflows/                # Workflow builder components
│   ├── ai/                       # AI-specific components
│   └── shared/                   # Shared components
├── lib/                          # Utility functions
│   ├── supabase/                 # Supabase client & helpers
│   ├── clerk/                    # Clerk auth helpers
│   ├── stripe/                   # Stripe integration
│   ├── ai/                       # AI model integrations
│   │   ├── gemini.ts             # Google Gemini
│   │   ├── groq.ts               # Groq
│   │   └── mcp.ts                # MCP integration
│   └── workflows/                # Workflow engine
├── prisma/                       # Database schema & migrations
│   ├── schema.prisma             # Prisma schema
│   ├── migrations/               # Database migrations
│   └── seed.ts                   # Seed data
├── public/                       # Static assets
├── docs/                         # Documentation
│   ├── API.md                    # API documentation
│   ├── DEPLOYMENT.md             # Deployment guide
│   ├── DATABASE.md               # Database schema
│   ├── WORKFLOWS.md              # Workflow guide
│   └── AI_INTEGRATION.md         # AI integration guide
├── scripts/                      # Utility scripts
│   ├── setup.sh                  # Initial setup
│   └── deploy.sh                 # Deployment script
├── .github/                      # GitHub configuration
│   └── workflows/                # GitHub Actions
│       ├── ci.yml                # Continuous Integration
│       └── deploy.yml            # Deployment workflow
├── .env.example                  # Environment variables template
├── next.config.js                # Next.js configuration
├── tailwind.config.ts            # Tailwind CSS configuration
├── tsconfig.json                 # TypeScript configuration
└── package.json                  # Dependencies
```

## 🔧 **Environment Setup**

Create a `.env.local` file in the root directory:

```env
# App Configuration
NEXT_PUBLIC_APP_NAME="AutomateAI"
NEXT_PUBLIC_APP_URL="http://localhost:3000"
NODE_ENV="development"

# Supabase
NEXT_PUBLIC_SUPABASE_URL="your-supabase-url"
NEXT_PUBLIC_SUPABASE_ANON_KEY="your-supabase-anon-key"
SUPABASE_SERVICE_ROLE_KEY="your-supabase-service-role-key"
DATABASE_URL="postgresql://postgres:[password]@db.[project-ref].supabase.co:5432/postgres"

# Clerk Authentication
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY="pk_test_..."
CLERK_SECRET_KEY="sk_test_..."
NEXT_PUBLIC_CLERK_SIGN_IN_URL="/sign-in"
NEXT_PUBLIC_CLERK_SIGN_UP_URL="/sign-up"
NEXT_PUBLIC_CLERK_AFTER_SIGN_IN_URL="/dashboard"
NEXT_PUBLIC_CLERK_AFTER_SIGN_UP_URL="/onboarding"

# Stripe
STRIPE_SECRET_KEY="sk_test_..."
STRIPE_WEBHOOK_SECRET="whsec_..."
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY="pk_test_..."
STRIPE_PRICE_ID_FREE="price_..."
STRIPE_PRICE_ID_PRO="price_..."
STRIPE_PRICE_ID_ENTERPRISE="price_..."

# AI Services
GOOGLE_GEMINI_API_KEY="your-gemini-api-key"
GROQ_API_KEY="your-groq-api-key"
OPENAI_API_KEY="sk-..."
ANTHROPIC_API_KEY="sk-ant-..."

# MCP Configuration
MCP_SERVER_URL="http://localhost:3001"
MCP_API_KEY="your-mcp-api-key"

# Analytics & Monitoring
NEXT_PUBLIC_POSTHOG_KEY="phc_..."
NEXT_PUBLIC_POSTHOG_HOST="https://app.posthog.com"
SENTRY_DSN="https://...@sentry.io/..."

# Email (Optional - for transactional emails)
RESEND_API_KEY="re_..."
EMAIL_FROM="noreply@yourdomain.com"
```

See [.env.example](.env.example) for complete configuration.

## 💾 **Database Setup**

### **Supabase Setup**

1. **Create Supabase Project**
   - Go to [supabase.com](https://supabase.com)
   - Create new project
   - Copy your project URL and keys

2. **Enable Required Extensions**
   ```sql
   -- Enable pgvector for AI embeddings
   CREATE EXTENSION IF NOT EXISTS vector;
   
   -- Enable UUID generation
   CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
   ```

3. **Run Migrations**
   ```bash
   npm run db:migrate
   ```

4. **Seed Database (Optional)**
   ```bash
   npm run db:seed
   ```

See [docs/DATABASE.md](docs/DATABASE.md) for detailed schema documentation.

## 🚀 **Deployment**

### **Deploy to Vercel**

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/itskiranbabu/automate-ai-saas)

**Manual Deployment:**

```bash
# 1. Install Vercel CLI
npm i -g vercel

# 2. Login to Vercel
vercel login

# 3. Deploy
vercel --prod
```

**Environment Variables:**
- Add all `.env.local` variables to Vercel dashboard
- Update `NEXT_PUBLIC_APP_URL` to your production domain

### **Post-Deployment Checklist**

- [ ] Configure custom domain in Vercel
- [ ] Set up Stripe webhooks (point to your domain)
- [ ] Configure Clerk production instance
- [ ] Enable Supabase production mode
- [ ] Set up monitoring (Sentry, PostHog)
- [ ] Configure email service (Resend)
- [ ] Test payment flow end-to-end
- [ ] Set up backup strategy

See [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) for detailed deployment guide.

## 💻 **Development**

### **Available Scripts**

```bash
# Development
npm run dev              # Start dev server
npm run build            # Build for production
npm run start            # Start production server
npm run lint             # Run ESLint
npm run type-check       # TypeScript type checking

# Database
npm run db:migrate       # Run Prisma migrations
npm run db:seed          # Seed database
npm run db:studio        # Open Prisma Studio
npm run db:reset         # Reset database (dev only)

# Testing
npm run test             # Run tests
npm run test:watch       # Run tests in watch mode
npm run test:coverage    # Generate coverage report

# Code Quality
npm run format           # Format code with Prettier
npm run format:check     # Check code formatting
```

### **Development Workflow**

1. Create a new branch: `git checkout -b feature/your-feature`
2. Make your changes
3. Run tests: `npm run test`
4. Commit: `git commit -m "feat: your feature"`
5. Push: `git push origin feature/your-feature`
6. Create Pull Request

## 📚 **Documentation**

- [API Documentation](docs/API.md) - Complete API reference
- [Database Schema](docs/DATABASE.md) - Database structure and relationships
- [Deployment Guide](docs/DEPLOYMENT.md) - Production deployment steps
- [Workflow Guide](docs/WORKFLOWS.md) - Creating and managing workflows
- [AI Integration](docs/AI_INTEGRATION.md) - AI model integration guide
- [MCP Guide](docs/MCP.md) - Model Context Protocol setup
- [Contributing](CONTRIBUTING.md) - Contribution guidelines

## 🎯 **Roadmap**

### **Phase 1: MVP (Weeks 1-2)** ✅
- [x] Project setup and infrastructure
- [x] Authentication with Clerk
- [x] Database schema and migrations
- [x] Basic workflow builder
- [x] Stripe integration

### **Phase 2: Core Features (Weeks 3-4)** 🚧
- [ ] AI model integrations (Gemini, Groq)
- [ ] Workflow templates marketplace
- [ ] Team collaboration features
- [ ] Advanced workflow editor
- [ ] Usage analytics dashboard

### **Phase 3: AI Enhancements (Weeks 5-6)** 📋
- [ ] MCP integration
- [ ] AI agent builder
- [ ] RAG implementation
- [ ] Vector search
- [ ] Custom AI models

### **Phase 4: Scale & Polish (Weeks 7-8)** 📋
- [ ] Performance optimization
- [ ] Advanced monitoring
- [ ] White-label options
- [ ] API marketplace
- [ ] Mobile app (React Native)

## 🤝 **Contributing**

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

### **Contributors**

<a href="https://github.com/itskiranbabu/automate-ai-saas/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=itskiranbabu/automate-ai-saas" />
</a>

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 **Acknowledgments**

- [n8n](https://n8n.io) - Workflow automation engine
- [Vercel](https://vercel.com) - Hosting platform
- [Supabase](https://supabase.com) - Database and backend
- [Clerk](https://clerk.com) - Authentication
- [Stripe](https://stripe.com) - Payment processing
- [shadcn/ui](https://ui.shadcn.com) - UI components

## 📞 **Support**

- 📧 Email: support@automateai.com
- 💬 Discord: [Join our community](https://discord.gg/automateai)
- 🐦 Twitter: [@automateai](https://twitter.com/automateai)
- 📖 Docs: [docs.automateai.com](https://docs.automateai.com)

## ⭐ **Star History**

[![Star History Chart](https://api.star-history.com/svg?repos=itskiranbabu/automate-ai-saas&type=Date)](https://star-history.com/#itskiranbabu/automate-ai-saas&Date)

---

**Built with ❤️ by [Kiran Babu](https://github.com/itskiranbabu)**

**Ready to automate? [Get Started →](https://automateai.com)**

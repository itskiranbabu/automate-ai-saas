# 🎯 MASTER PROMPT FOR CURSOR/WINDSURF AI

**Copy this entire prompt into Cursor or Windsurf AI to build the complete AutomateAI SaaS platform.**

---

## PROJECT OVERVIEW

Build a **production-ready AI automation SaaS platform** combining:
- **n8n-inspired workflow automation** with visual builder
- **Complete SaaS infrastructure** (auth, billing, subscriptions)
- **Multi-AI support** (Gemini, Groq, OpenAI, Claude)
- **Model Context Protocol (MCP)** integration
- **Deployed on Vercel + Supabase**

**Target:** Launch-ready SaaS in 6-8 weeks with monetization built-in.

---

## TECH STACK (NON-NEGOTIABLE)

### Frontend
- **Framework**: Next.js 14 (App Router) with TypeScript
- **Styling**: Tailwind CSS + shadcn/ui components
- **State**: Zustand for global state
- **Forms**: React Hook Form + Zod validation
- **API**: TanStack Query (React Query)

### Backend
- **Runtime**: Node.js 20+
- **API**: Next.js API Routes + tRPC
- **Database**: Supabase (PostgreSQL)
- **ORM**: Prisma
- **Auth**: Clerk (NOT NextAuth)
- **Payments**: Stripe with webhooks

### AI & Automation
- **Primary AI**: Google Gemini (gemini-1.5-flash)
- **Fast AI**: Groq (llama3-70b-8192)
- **Optional**: OpenAI, Claude
- **MCP**: Model Context Protocol for tool use
- **Vector DB**: Supabase pgvector for RAG

### DevOps
- **Hosting**: Vercel (frontend + API)
- **Database**: Supabase (PostgreSQL + Storage)
- **Monitoring**: Sentry + PostHog
- **Analytics**: Vercel Analytics

---

## PROJECT STRUCTURE

```
automate-ai-saas/
├── app/
│   ├── (auth)/
│   │   ├── sign-in/[[...sign-in]]/page.tsx
│   │   └── sign-up/[[...sign-up]]/page.tsx
│   ├── (dashboard)/
│   │   ├── dashboard/page.tsx
│   │   ├── workflows/
│   │   │   ├── page.tsx
│   │   │   ├── [id]/page.tsx
│   │   │   └── new/page.tsx
│   │   ├── templates/page.tsx
│   │   ├── settings/page.tsx
│   │   └── billing/page.tsx
│   ├── (marketing)/
│   │   ├── page.tsx (landing)
│   │   ├── pricing/page.tsx
│   │   └── docs/page.tsx
│   ├── api/
│   │   ├── webhooks/
│   │   │   ├── clerk/route.ts
│   │   │   └── stripe/route.ts
│   │   ├── workflows/
│   │   │   ├── route.ts
│   │   │   └── [id]/route.ts
│   │   ├── ai/
│   │   │   ├── gemini/route.ts
│   │   │   ├── groq/route.ts
│   │   │   └── chat/route.ts
│   │   └── mcp/route.ts
│   └── layout.tsx
├── components/
│   ├── ui/ (shadcn components)
│   ├── workflows/
│   │   ├── WorkflowBuilder.tsx
│   │   ├── NodeEditor.tsx
│   │   └── ExecutionLog.tsx
│   ├── ai/
│   │   ├── ChatInterface.tsx
│   │   └── ModelSelector.tsx
│   └── shared/
│       ├── Navbar.tsx
│       └── Footer.tsx
├── lib/
│   ├── supabase/
│   │   ├── client.ts
│   │   └── server.ts
│   ├── clerk/
│   │   └── auth.ts
│   ├── stripe/
│   │   ├── client.ts
│   │   └── webhooks.ts
│   ├── ai/
│   │   ├── gemini.ts
│   │   ├── groq.ts
│   │   ├── openai.ts
│   │   ├── claude.ts
│   │   └── embeddings.ts
│   ├── mcp/
│   │   ├── server.ts
│   │   └── client.ts
│   ├── workflows/
│   │   ├── engine.ts
│   │   ├── executor.ts
│   │   └── nodes/
│   └── utils.ts
├── prisma/
│   ├── schema.prisma
│   ├── migrations/
│   └── seed.ts
├── docs/
│   ├── DATABASE.md
│   ├── DEPLOYMENT.md
│   ├── AI_INTEGRATION.md
│   └── API.md
├── .env.example
├── next.config.js
├── tailwind.config.ts
└── package.json
```

---

## PHASE 1: FOUNDATION (Week 1)

### Step 1.1: Initialize Project

```bash
# Create Next.js project
npx create-next-app@latest automate-ai-saas --typescript --tailwind --app --src-dir=false

cd automate-ai-saas

# Install core dependencies
npm install @clerk/nextjs @supabase/supabase-js @prisma/client stripe
npm install @tanstack/react-query zustand react-hook-form zod
npm install @google/generative-ai groq-sdk openai @anthropic-ai/sdk

# Install UI components
npx shadcn-ui@latest init
npx shadcn-ui@latest add button input label select textarea card dialog dropdown-menu

# Install dev dependencies
npm install -D prisma @types/node tsx
```

### Step 1.2: Configure Environment

Create `.env.local` with ALL required variables from `.env.example`.

**CRITICAL**: Do NOT proceed without setting up:
- Supabase URL and keys
- Clerk publishable and secret keys
- Stripe keys and webhook secret
- At least ONE AI API key (Gemini recommended)

### Step 1.3: Set Up Database

```bash
# Initialize Prisma
npx prisma init

# Copy schema from prisma/schema.prisma
# Run migrations
npx prisma migrate dev --name init

# Generate Prisma client
npx prisma generate
```

### Step 1.4: Configure Clerk

1. Create Clerk application
2. Enable Google and GitHub OAuth
3. Set up webhook endpoint
4. Configure appearance to match brand

Create `middleware.ts`:

```typescript
import { authMiddleware } from "@clerk/nextjs";

export default authMiddleware({
  publicRoutes: ["/", "/pricing", "/docs", "/api/webhooks/(.*)"],
});

export const config = {
  matcher: ["/((?!.+\\.[\\w]+$|_next).*)", "/", "/(api|trpc)(.*)"],
};
```

### Step 1.5: Set Up Supabase Client

Create `lib/supabase/client.ts`:

```typescript
import { createClient } from '@supabase/supabase-js';

export const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
);
```

---

## PHASE 2: CORE FEATURES (Weeks 2-3)

### Step 2.1: Authentication Flow

**Files to create:**
- `app/(auth)/sign-in/[[...sign-in]]/page.tsx`
- `app/(auth)/sign-up/[[...sign-up]]/page.tsx`
- `app/(auth)/layout.tsx`

**Implementation:**
```typescript
// app/(auth)/sign-in/[[...sign-in]]/page.tsx
import { SignIn } from "@clerk/nextjs";

export default function SignInPage() {
  return (
    <div className="flex min-h-screen items-center justify-center">
      <SignIn />
    </div>
  );
}
```

**Webhook handler:**
```typescript
// app/api/webhooks/clerk/route.ts
import { Webhook } from 'svix';
import { headers } from 'next/headers';
import { prisma } from '@/lib/prisma';

export async function POST(req: Request) {
  const WEBHOOK_SECRET = process.env.CLERK_WEBHOOK_SECRET;
  const headerPayload = headers();
  const svix_id = headerPayload.get("svix-id");
  const svix_timestamp = headerPayload.get("svix-timestamp");
  const svix_signature = headerPayload.get("svix-signature");

  const body = await req.text();
  const wh = new Webhook(WEBHOOK_SECRET!);
  
  let evt;
  try {
    evt = wh.verify(body, {
      "svix-id": svix_id!,
      "svix-timestamp": svix_timestamp!,
      "svix-signature": svix_signature!,
    });
  } catch (err) {
    return new Response('Error verifying webhook', { status: 400 });
  }

  const { id, email_addresses, first_name, last_name, image_url } = evt.data;
  const eventType = evt.type;

  if (eventType === 'user.created') {
    await prisma.user.create({
      data: {
        clerkId: id,
        email: email_addresses[0].email_address,
        firstName: first_name,
        lastName: last_name,
        imageUrl: image_url,
        subscriptionTier: 'FREE',
        subscriptionStatus: 'ACTIVE',
      },
    });
  }

  return new Response('', { status: 200 });
}
```

### Step 2.2: Stripe Integration

**Create subscription plans:**

```typescript
// lib/stripe/plans.ts
export const SUBSCRIPTION_PLANS = {
  FREE: {
    name: 'Free',
    price: 0,
    priceId: process.env.STRIPE_PRICE_ID_FREE,
    features: [
      '5 workflows',
      '1,000 executions/month',
      'Basic integrations',
      'Community support',
    ],
    limits: {
      workflows: 5,
      executionsPerMonth: 1000,
      storage: 100 * 1024 * 1024, // 100MB
    },
  },
  PRO: {
    name: 'Pro',
    price: 29,
    priceId: process.env.STRIPE_PRICE_ID_PRO,
    features: [
      '50 workflows',
      '50,000 executions/month',
      'All integrations',
      'AI features',
      'Priority support',
    ],
    limits: {
      workflows: 50,
      executionsPerMonth: 50000,
      storage: 10 * 1024 * 1024 * 1024, // 10GB
    },
  },
  ENTERPRISE: {
    name: 'Enterprise',
    price: 299,
    priceId: process.env.STRIPE_PRICE_ID_ENTERPRISE,
    features: [
      'Unlimited workflows',
      'Unlimited executions',
      'White-label',
      'Dedicated support',
      'Custom integrations',
    ],
    limits: {
      workflows: -1, // unlimited
      executionsPerMonth: -1,
      storage: -1,
    },
  },
};
```

**Checkout session:**

```typescript
// app/api/stripe/checkout/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@clerk/nextjs';
import Stripe from 'stripe';
import { prisma } from '@/lib/prisma';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2023-10-16',
});

export async function POST(req: NextRequest) {
  const { userId } = auth();
  if (!userId) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  const { priceId } = await req.json();

  const user = await prisma.user.findUnique({
    where: { clerkId: userId },
  });

  const session = await stripe.checkout.sessions.create({
    customer_email: user!.email,
    line_items: [{ price: priceId, quantity: 1 }],
    mode: 'subscription',
    success_url: `${process.env.NEXT_PUBLIC_APP_URL}/dashboard?success=true`,
    cancel_url: `${process.env.NEXT_PUBLIC_APP_URL}/pricing?canceled=true`,
    metadata: { userId: user!.id },
  });

  return NextResponse.json({ url: session.url });
}
```

**Webhook handler:**

```typescript
// app/api/webhooks/stripe/route.ts
import { NextRequest, NextResponse } from 'next/server';
import Stripe from 'stripe';
import { prisma } from '@/lib/prisma';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!);

export async function POST(req: NextRequest) {
  const body = await req.text();
  const sig = req.headers.get('stripe-signature')!;

  let event: Stripe.Event;

  try {
    event = stripe.webhooks.constructEvent(
      body,
      sig,
      process.env.STRIPE_WEBHOOK_SECRET!
    );
  } catch (err) {
    return NextResponse.json({ error: 'Webhook error' }, { status: 400 });
  }

  switch (event.type) {
    case 'checkout.session.completed':
      const session = event.data.object as Stripe.Checkout.Session;
      await handleCheckoutCompleted(session);
      break;
    case 'customer.subscription.updated':
      const subscription = event.data.object as Stripe.Subscription;
      await handleSubscriptionUpdated(subscription);
      break;
    case 'customer.subscription.deleted':
      const deletedSub = event.data.object as Stripe.Subscription;
      await handleSubscriptionDeleted(deletedSub);
      break;
  }

  return NextResponse.json({ received: true });
}

async function handleCheckoutCompleted(session: Stripe.Checkout.Session) {
  const userId = session.metadata?.userId;
  
  await prisma.user.update({
    where: { id: userId },
    data: {
      stripeCustomerId: session.customer as string,
      stripeSubscriptionId: session.subscription as string,
      subscriptionTier: 'PRO',
      subscriptionStatus: 'ACTIVE',
    },
  });
}
```

### Step 2.3: AI Integration

**Gemini client:**

```typescript
// lib/ai/gemini.ts
import { GoogleGenerativeAI } from '@google/generative-ai';

const genAI = new GoogleGenerativeAI(process.env.GOOGLE_GEMINI_API_KEY!);

export async function generateWithGemini(prompt: string) {
  const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });
  const result = await model.generateContent(prompt);
  return result.response.text();
}

export async function chatWithGemini(messages: Array<{role: string, content: string}>) {
  const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });
  
  const chat = model.startChat({
    history: messages.slice(0, -1).map(msg => ({
      role: msg.role === 'user' ? 'user' : 'model',
      parts: [{ text: msg.content }],
    })),
  });
  
  const lastMessage = messages[messages.length - 1];
  const result = await chat.sendMessage(lastMessage.content);
  return result.response.text();
}
```

**API route:**

```typescript
// app/api/ai/chat/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@clerk/nextjs';
import { chatWithGemini } from '@/lib/ai/gemini';

export async function POST(req: NextRequest) {
  const { userId } = auth();
  if (!userId) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  const { messages } = await req.json();
  
  try {
    const response = await chatWithGemini(messages);
    return NextResponse.json({ response });
  } catch (error) {
    console.error('AI error:', error);
    return NextResponse.json(
      { error: 'Failed to generate response' },
      { status: 500 }
    );
  }
}
```

---

## PHASE 3: WORKFLOW ENGINE (Week 4)

### Step 3.1: Workflow Data Model

Already defined in `prisma/schema.prisma`. Key models:
- `Workflow`: Stores workflow definition
- `WorkflowExecution`: Tracks execution history
- `WorkflowTrigger`: Defines triggers
- `WorkflowSchedule`: Cron schedules

### Step 3.2: Workflow Builder UI

**Create visual workflow builder:**

```typescript
// components/workflows/WorkflowBuilder.tsx
'use client';

import { useState } from 'react';
import ReactFlow, { 
  Node, 
  Edge, 
  Controls, 
  Background 
} from 'reactflow';
import 'reactflow/dist/style.css';

export function WorkflowBuilder() {
  const [nodes, setNodes] = useState<Node[]>([]);
  const [edges, setEdges] = useState<Edge[]>([]);

  return (
    <div className="h-screen w-full">
      <ReactFlow
        nodes={nodes}
        edges={edges}
        onNodesChange={(changes) => {
          // Handle node changes
        }}
        onEdgesChange={(changes) => {
          // Handle edge changes
        }}
      >
        <Controls />
        <Background />
      </ReactFlow>
    </div>
  );
}
```

### Step 3.3: Workflow Execution Engine

```typescript
// lib/workflows/executor.ts
import { prisma } from '@/lib/prisma';

export async function executeWorkflow(workflowId: string, inputData: any) {
  const workflow = await prisma.workflow.findUnique({
    where: { id: workflowId },
  });

  if (!workflow) {
    throw new Error('Workflow not found');
  }

  // Create execution record
  const execution = await prisma.workflowExecution.create({
    data: {
      workflowId,
      userId: workflow.userId,
      status: 'RUNNING',
      inputData,
    },
  });

  try {
    // Execute workflow nodes
    const result = await executeNodes(workflow.nodes, workflow.connections, inputData);

    // Update execution
    await prisma.workflowExecution.update({
      where: { id: execution.id },
      data: {
        status: 'SUCCESS',
        outputData: result,
        finishedAt: new Date(),
        duration: Date.now() - execution.startedAt.getTime(),
      },
    });

    return result;
  } catch (error) {
    // Handle error
    await prisma.workflowExecution.update({
      where: { id: execution.id },
      data: {
        status: 'FAILED',
        errorData: { message: error.message },
        finishedAt: new Date(),
      },
    });

    throw error;
  }
}

async function executeNodes(nodes: any, connections: any, inputData: any) {
  // Implementation of node execution logic
  // This is where you execute each node in the workflow
  return {};
}
```

---

## PHASE 4: MCP INTEGRATION (Week 5)

### Step 4.1: MCP Server

```typescript
// lib/mcp/server.ts
export class MCPServer {
  registerTool(name: string, handler: Function) {
    // Register tool
  }

  async start(port: number) {
    // Start server
  }
}
```

### Step 4.2: MCP Tools

Register workflow execution, database queries, and document search as MCP tools.

---

## PHASE 5: UI/UX POLISH (Week 6)

### Step 5.1: Landing Page

Create beautiful landing page with:
- Hero section
- Features showcase
- Pricing table
- Testimonials
- CTA buttons

### Step 5.2: Dashboard

Create comprehensive dashboard with:
- Workflow list
- Execution stats
- Usage metrics
- Quick actions

---

## PHASE 6: DEPLOYMENT (Week 7)

### Step 6.1: Vercel Deployment

```bash
vercel --prod
```

### Step 6.2: Configure Production

- Set all environment variables
- Update webhook URLs
- Enable production mode in Clerk and Stripe
- Test payment flow

---

## CRITICAL REQUIREMENTS

### ✅ Must Have
1. All environment variables configured
2. Database migrations run
3. Clerk webhooks working
4. Stripe webhooks working
5. At least one AI model integrated (Gemini)
6. Basic workflow execution working
7. Payment flow tested end-to-end

### ❌ Do NOT
1. Use NextAuth (use Clerk)
2. Use MongoDB (use Supabase PostgreSQL)
3. Skip error handling
4. Hardcode API keys
5. Deploy without testing webhooks
6. Skip database indexes
7. Ignore TypeScript errors

### 🎯 Success Criteria
- User can sign up and sign in
- User can create and execute workflows
- User can upgrade to paid plan
- AI features work correctly
- No console errors
- All TypeScript types correct
- Database queries optimized
- Webhooks handle all events

---

## TESTING CHECKLIST

- [ ] Sign up flow works
- [ ] Sign in flow works
- [ ] OAuth providers work
- [ ] Create workflow
- [ ] Execute workflow
- [ ] View execution logs
- [ ] Upgrade to Pro plan
- [ ] Payment succeeds
- [ ] Subscription updates in database
- [ ] AI chat works
- [ ] Workflow templates load
- [ ] Settings page works
- [ ] Billing page shows subscription

---

## DEPLOYMENT CHECKLIST

- [ ] All environment variables set in Vercel
- [ ] Database migrations deployed
- [ ] Clerk production instance configured
- [ ] Stripe production mode enabled
- [ ] Webhook URLs updated
- [ ] Custom domain configured
- [ ] SSL certificate active
- [ ] Analytics tracking
- [ ] Error monitoring active
- [ ] Backup strategy in place

---

## SUPPORT & RESOURCES

- **Repository**: https://github.com/itskiranbabu/automate-ai-saas
- **Documentation**: See `/docs` folder
- **Database Schema**: `docs/DATABASE.md`
- **Deployment Guide**: `docs/DEPLOYMENT.md`
- **AI Integration**: `docs/AI_INTEGRATION.md`

---

## FINAL NOTES

This prompt is designed to be comprehensive and production-ready. Follow it step-by-step, and you'll have a fully functional SaaS platform.

**DO NOT SKIP STEPS**. Each phase builds on the previous one.

**TEST FREQUENTLY**. Don't wait until the end to test features.

**ASK FOR HELP**. If stuck, refer to documentation or open an issue.

**GOOD LUCK!** 🚀

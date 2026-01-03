# 📊 Database Schema Documentation

## Overview

This document describes the complete database schema for the AutomateAI SaaS platform. The database is built on **PostgreSQL** (via Supabase) with **Prisma ORM**.

## Table of Contents

- [Core Entities](#core-entities)
- [Relationships](#relationships)
- [Indexes](#indexes)
- [Extensions](#extensions)
- [Migration Guide](#migration-guide)

## Core Entities

### 👤 User Management

#### **User**
Primary user entity integrated with Clerk authentication.

```prisma
model User {
  id            String    @id @default(uuid())
  clerkId       String    @unique
  email         String    @unique
  firstName     String?
  lastName      String?
  imageUrl      String?
  username      String?   @unique
  
  subscriptionTier    SubscriptionTier
  subscriptionStatus  SubscriptionStatus
  stripeCustomerId    String?   @unique
  stripeSubscriptionId String?  @unique
  
  workflowsUsed       Int       @default(0)
  executionsThisMonth Int       @default(0)
  storageUsed         Int       @default(0)
}
```

**Key Fields:**
- `clerkId`: Unique identifier from Clerk authentication
- `subscriptionTier`: FREE, PRO, or ENTERPRISE
- `workflowsUsed`: Current workflow count (for limits)
- `executionsThisMonth`: Monthly execution counter

**Subscription Tiers:**
```typescript
FREE: {
  workflowLimit: 5,
  executionsPerMonth: 1000,
  storageLimit: 100MB
}

PRO: {
  workflowLimit: 50,
  executionsPerMonth: 50000,
  storageLimit: 10GB
}

ENTERPRISE: {
  workflowLimit: unlimited,
  executionsPerMonth: unlimited,
  storageLimit: unlimited
}
```

### 🔄 Workflow System

#### **Workflow**
Core workflow entity containing automation logic.

```prisma
model Workflow {
  id          String   @id @default(uuid())
  name        String
  description String?
  
  nodes       Json     // Workflow nodes
  connections Json     // Node connections
  settings    Json?    // Configuration
  
  status      WorkflowStatus
  isActive    Boolean
  isPublic    Boolean
  
  userId      String
  teamId      String?
  
  totalExecutions      Int
  successfulExecutions Int
  failedExecutions     Int
}
```

**Node Structure (JSON):**
```json
{
  "nodes": [
    {
      "id": "node-1",
      "type": "trigger",
      "name": "Webhook Trigger",
      "position": { "x": 100, "y": 100 },
      "data": {
        "webhookUrl": "https://...",
        "method": "POST"
      }
    },
    {
      "id": "node-2",
      "type": "ai",
      "name": "Gemini AI",
      "position": { "x": 300, "y": 100 },
      "data": {
        "model": "gemini-1.5-flash",
        "prompt": "{{input.text}}",
        "temperature": 0.7
      }
    }
  ],
  "connections": [
    {
      "source": "node-1",
      "target": "node-2",
      "sourceHandle": "output",
      "targetHandle": "input"
    }
  ]
}
```

#### **WorkflowExecution**
Tracks individual workflow runs.

```prisma
model WorkflowExecution {
  id          String   @id @default(uuid())
  workflowId  String
  userId      String
  
  status      ExecutionStatus
  startedAt   DateTime
  finishedAt  DateTime?
  duration    Int?
  
  inputData   Json?
  outputData  Json?
  errorData   Json?
  logs        Json[]
  
  triggeredBy String?
  retryCount  Int
}
```

**Execution Statuses:**
- `RUNNING`: Currently executing
- `SUCCESS`: Completed successfully
- `FAILED`: Execution failed
- `CANCELED`: Manually canceled
- `TIMEOUT`: Exceeded time limit

### 🤖 AI Integration

#### **AIModel**
Manages AI model configurations.

```prisma
model AIModel {
  id          String   @id @default(uuid())
  name        String
  provider    AIProvider
  modelId     String
  
  config      Json
  isActive    Boolean
  
  totalRequests    Int
  totalTokens      Int
  totalCost        Float
}
```

**Supported Providers:**
- `GEMINI`: Google Gemini (gemini-1.5-flash, gemini-pro)
- `GROQ`: Groq (llama3-70b, mixtral-8x7b)
- `OPENAI`: OpenAI (gpt-4, gpt-3.5-turbo)
- `ANTHROPIC`: Anthropic (claude-3-opus)
- `CUSTOM`: Custom model endpoints

**Model Configuration Example:**
```json
{
  "apiKey": "encrypted-key",
  "endpoint": "https://api.provider.com",
  "maxTokens": 2048,
  "temperature": 0.7,
  "topP": 0.9,
  "frequencyPenalty": 0,
  "presencePenalty": 0
}
```

#### **AIConversation**
Stores AI chat conversations.

```prisma
model AIConversation {
  id          String   @id @default(uuid())
  userId      String
  modelId     String
  
  title       String?
  messages    Json[]
  
  tokensUsed  Int
  cost        Float
}
```

**Message Format:**
```json
{
  "messages": [
    {
      "role": "user",
      "content": "Hello, how are you?",
      "timestamp": "2024-01-01T00:00:00Z"
    },
    {
      "role": "assistant",
      "content": "I'm doing well, thank you!",
      "timestamp": "2024-01-01T00:00:01Z",
      "tokensUsed": 15
    }
  ]
}
```

### 📚 Vector Embeddings (RAG)

#### **Document**
Stores documents with vector embeddings for semantic search.

```prisma
model Document {
  id          String   @id @default(uuid())
  userId      String
  
  title       String
  content     String
  metadata    Json?
  
  embedding   Unsupported("vector(1536)")?
  
  sourceType  String?
  sourceUrl   String?
}
```

**Vector Search Query:**
```sql
-- Find similar documents using cosine similarity
SELECT id, title, content,
  1 - (embedding <=> '[0.1, 0.2, ...]'::vector) AS similarity
FROM "Document"
WHERE userId = 'user-id'
ORDER BY similarity DESC
LIMIT 10;
```

### 👥 Team Collaboration

#### **Team**
Organization/team entity.

```prisma
model Team {
  id          String   @id @default(uuid())
  name        String
  slug        String   @unique
  
  subscriptionTier SubscriptionTier
}
```

#### **TeamMember**
Team membership with roles.

```prisma
model TeamMember {
  id          String   @id @default(uuid())
  teamId      String
  userId      String
  role        TeamRole
  
  joinedAt    DateTime
}
```

**Team Roles:**
- `OWNER`: Full control, billing access
- `ADMIN`: Manage members, workflows
- `MEMBER`: Create and edit workflows
- `VIEWER`: Read-only access

## Relationships

### Entity Relationship Diagram

```
User
├── Workflows (1:N)
├── WorkflowExecutions (1:N)
├── ApiKeys (1:N)
├── TeamMembers (1:N)
├── Notifications (1:N)
└── UsageLogs (1:N)

Workflow
├── WorkflowExecutions (1:N)
├── WorkflowTriggers (1:N)
├── WorkflowSchedules (1:N)
└── WorkflowVersions (1:N)

Team
├── TeamMembers (1:N)
└── Workflows (1:N)

AIModel
└── AIConversations (1:N)
```

## Indexes

### Performance Indexes

```sql
-- User indexes
CREATE INDEX idx_user_clerk_id ON "User"(clerkId);
CREATE INDEX idx_user_email ON "User"(email);
CREATE INDEX idx_user_subscription ON "User"(subscriptionTier);

-- Workflow indexes
CREATE INDEX idx_workflow_user ON "Workflow"(userId);
CREATE INDEX idx_workflow_status ON "Workflow"(status);
CREATE INDEX idx_workflow_category ON "Workflow"(category);
CREATE INDEX idx_workflow_public ON "Workflow"(isPublic);

-- Execution indexes
CREATE INDEX idx_execution_workflow ON "WorkflowExecution"(workflowId);
CREATE INDEX idx_execution_user ON "WorkflowExecution"(userId);
CREATE INDEX idx_execution_status ON "WorkflowExecution"(status);
CREATE INDEX idx_execution_started ON "WorkflowExecution"(startedAt);

-- AI indexes
CREATE INDEX idx_ai_provider ON "AIModel"(provider);
CREATE INDEX idx_conversation_user ON "AIConversation"(userId);
CREATE INDEX idx_conversation_model ON "AIConversation"(modelId);

-- Document indexes (vector search)
CREATE INDEX idx_document_user ON "Document"(userId);
CREATE INDEX idx_document_embedding ON "Document" USING ivfflat (embedding vector_cosine_ops);
```

## Extensions

### Required PostgreSQL Extensions

```sql
-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable vector operations (for RAG)
CREATE EXTENSION IF NOT EXISTS vector;

-- Enable full-text search
CREATE EXTENSION IF NOT EXISTS pg_trgm;
```

## Migration Guide

### Initial Setup

```bash
# 1. Install dependencies
npm install

# 2. Generate Prisma client
npm run db:generate

# 3. Create migration
npx prisma migrate dev --name init

# 4. Apply migration
npm run db:migrate

# 5. Seed database (optional)
npm run db:seed
```

### Creating Migrations

```bash
# Create a new migration
npx prisma migrate dev --name add_new_feature

# Apply migrations in production
npm run db:migrate:deploy

# Reset database (development only)
npm run db:reset
```

### Seeding Data

Create `prisma/seed.ts`:

```typescript
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  // Create sample AI models
  await prisma.aIModel.createMany({
    data: [
      {
        name: 'Gemini 1.5 Flash',
        provider: 'GEMINI',
        modelId: 'gemini-1.5-flash',
        config: {
          maxTokens: 2048,
          temperature: 0.7,
        },
        isActive: true,
      },
      {
        name: 'Llama 3 70B',
        provider: 'GROQ',
        modelId: 'llama3-70b-8192',
        config: {
          maxTokens: 8192,
          temperature: 0.7,
        },
        isActive: true,
      },
    ],
  });

  // Create sample templates
  await prisma.template.createMany({
    data: [
      {
        name: 'AI Content Generator',
        description: 'Generate blog posts with AI',
        category: 'Marketing',
        tags: ['ai', 'content', 'marketing'],
        nodes: {},
        connections: {},
        price: 0,
        authorId: 'system',
        authorName: 'AutomateAI',
        isPublished: true,
        isFeatured: true,
      },
    ],
  });
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
```

## Backup & Recovery

### Automated Backups

Supabase provides automatic daily backups. For additional safety:

```bash
# Manual backup
pg_dump $DATABASE_URL > backup_$(date +%Y%m%d).sql

# Restore from backup
psql $DATABASE_URL < backup_20240101.sql
```

### Point-in-Time Recovery

Supabase Pro plan includes Point-in-Time Recovery (PITR):
- Restore to any point in the last 7 days
- Access via Supabase dashboard

## Performance Optimization

### Query Optimization

```typescript
// ❌ Bad: N+1 query problem
const workflows = await prisma.workflow.findMany();
for (const workflow of workflows) {
  const executions = await prisma.workflowExecution.findMany({
    where: { workflowId: workflow.id }
  });
}

// ✅ Good: Use include
const workflows = await prisma.workflow.findMany({
  include: {
    executions: true
  }
});
```

### Connection Pooling

```typescript
// lib/prisma.ts
import { PrismaClient } from '@prisma/client';

const globalForPrisma = global as unknown as { prisma: PrismaClient };

export const prisma =
  globalForPrisma.prisma ||
  new PrismaClient({
    log: ['query', 'error', 'warn'],
  });

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;
```

## Security Best Practices

### Row Level Security (RLS)

Enable RLS in Supabase:

```sql
-- Enable RLS on User table
ALTER TABLE "User" ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own data
CREATE POLICY user_select_own ON "User"
  FOR SELECT
  USING (auth.uid() = clerkId);

-- Policy: Users can only update their own data
CREATE POLICY user_update_own ON "User"
  FOR UPDATE
  USING (auth.uid() = clerkId);
```

### Data Encryption

```typescript
// Encrypt sensitive data before storing
import { encrypt, decrypt } from '@/lib/encryption';

// Store encrypted API key
const encryptedKey = encrypt(apiKey);
await prisma.apiKey.create({
  data: {
    key: encryptedKey,
    // ...
  }
});

// Decrypt when retrieving
const apiKey = await prisma.apiKey.findUnique({ where: { id } });
const decryptedKey = decrypt(apiKey.key);
```

## Monitoring

### Query Performance

```typescript
// Enable query logging
const prisma = new PrismaClient({
  log: [
    { emit: 'event', level: 'query' },
    { emit: 'stdout', level: 'error' },
  ],
});

prisma.$on('query', (e) => {
  console.log('Query: ' + e.query);
  console.log('Duration: ' + e.duration + 'ms');
});
```

### Database Metrics

Monitor in Supabase dashboard:
- Connection count
- Query performance
- Table sizes
- Index usage
- Slow queries

## Troubleshooting

### Common Issues

**Issue: Migration fails**
```bash
# Reset migrations (dev only)
npx prisma migrate reset

# Force push schema
npx prisma db push --force-reset
```

**Issue: Connection pool exhausted**
```typescript
// Increase connection pool size
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
  connectionLimit = 20
}
```

**Issue: Slow queries**
```sql
-- Analyze query performance
EXPLAIN ANALYZE
SELECT * FROM "Workflow" WHERE userId = 'user-id';

-- Add missing indexes
CREATE INDEX idx_workflow_user ON "Workflow"(userId);
```

## Resources

- [Prisma Documentation](https://www.prisma.io/docs)
- [Supabase Documentation](https://supabase.com/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [pgvector Documentation](https://github.com/pgvector/pgvector)

---

**Need help?** Open an issue on [GitHub](https://github.com/itskiranbabu/automate-ai-saas/issues)

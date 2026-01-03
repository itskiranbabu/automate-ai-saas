# 🤖 AI Integration Guide

Complete guide to integrating AI models (Gemini, Groq, OpenAI, Claude) and Model Context Protocol (MCP) into AutomateAI.

## Table of Contents

- [Overview](#overview)
- [Google Gemini](#google-gemini)
- [Groq](#groq)
- [OpenAI](#openai)
- [Anthropic Claude](#anthropic-claude)
- [Model Context Protocol (MCP)](#model-context-protocol-mcp)
- [RAG Implementation](#rag-implementation)
- [Best Practices](#best-practices)

## Overview

AutomateAI supports multiple AI providers with a unified interface. All AI integrations are located in `lib/ai/`.

### Supported Models

| Provider | Models | Speed | Cost | Best For |
|----------|--------|-------|------|----------|
| **Gemini** | gemini-1.5-flash, gemini-pro | ⚡⚡⚡ | 💰 | Fast, cost-effective |
| **Groq** | llama3-70b, mixtral-8x7b | ⚡⚡⚡⚡ | 💰 | Ultra-fast inference |
| **OpenAI** | gpt-4, gpt-3.5-turbo | ⚡⚡ | 💰💰💰 | High quality |
| **Claude** | claude-3-opus | ⚡⚡ | 💰💰💰 | Complex reasoning |

## Google Gemini

### Setup

1. **Get API Key**
   - Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Click "Create API Key"
   - Copy the key

2. **Add to Environment**
   ```env
   GOOGLE_GEMINI_API_KEY="your-api-key"
   GEMINI_MODEL="gemini-1.5-flash"
   ```

### Implementation

Create `lib/ai/gemini.ts`:

```typescript
import { GoogleGenerativeAI } from '@google/generative-ai';

const genAI = new GoogleGenerativeAI(process.env.GOOGLE_GEMINI_API_KEY!);

export interface GeminiConfig {
  model?: string;
  temperature?: number;
  maxTokens?: number;
  topP?: number;
  topK?: number;
}

export class GeminiClient {
  private model: any;
  
  constructor(config: GeminiConfig = {}) {
    const modelName = config.model || 'gemini-1.5-flash';
    this.model = genAI.getGenerativeModel({
      model: modelName,
      generationConfig: {
        temperature: config.temperature || 0.7,
        maxOutputTokens: config.maxTokens || 2048,
        topP: config.topP || 0.95,
        topK: config.topK || 40,
      },
    });
  }
  
  async generateText(prompt: string): Promise<string> {
    try {
      const result = await this.model.generateContent(prompt);
      const response = await result.response;
      return response.text();
    } catch (error) {
      console.error('Gemini API error:', error);
      throw new Error('Failed to generate text with Gemini');
    }
  }
  
  async chat(messages: Array<{ role: string; content: string }>) {
    const chat = this.model.startChat({
      history: messages.slice(0, -1).map(msg => ({
        role: msg.role === 'user' ? 'user' : 'model',
        parts: [{ text: msg.content }],
      })),
    });
    
    const lastMessage = messages[messages.length - 1];
    const result = await chat.sendMessage(lastMessage.content);
    const response = await result.response;
    
    return {
      content: response.text(),
      tokensUsed: response.usageMetadata?.totalTokenCount || 0,
    };
  }
  
  async generateWithStreaming(
    prompt: string,
    onChunk: (chunk: string) => void
  ): Promise<void> {
    const result = await this.model.generateContentStream(prompt);
    
    for await (const chunk of result.stream) {
      const chunkText = chunk.text();
      onChunk(chunkText);
    }
  }
  
  async analyzeImage(imageData: string, prompt: string): Promise<string> {
    const imagePart = {
      inlineData: {
        data: imageData,
        mimeType: 'image/jpeg',
      },
    };
    
    const result = await this.model.generateContent([prompt, imagePart]);
    const response = await result.response;
    return response.text();
  }
}

// Usage example
export async function generateWithGemini(prompt: string) {
  const client = new GeminiClient({
    model: 'gemini-1.5-flash',
    temperature: 0.7,
  });
  
  return await client.generateText(prompt);
}
```

### API Route Example

Create `app/api/ai/gemini/route.ts`:

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { GeminiClient } from '@/lib/ai/gemini';
import { auth } from '@clerk/nextjs';

export async function POST(req: NextRequest) {
  try {
    const { userId } = auth();
    if (!userId) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    const { prompt, model, temperature } = await req.json();
    
    const client = new GeminiClient({ model, temperature });
    const response = await client.generateText(prompt);
    
    // Track usage
    await trackAIUsage(userId, 'gemini', response.length);
    
    return NextResponse.json({ response });
  } catch (error) {
    console.error('Gemini API error:', error);
    return NextResponse.json(
      { error: 'Failed to generate response' },
      { status: 500 }
    );
  }
}
```

### Streaming Response

```typescript
export async function POST(req: NextRequest) {
  const { prompt } = await req.json();
  
  const encoder = new TextEncoder();
  const stream = new ReadableStream({
    async start(controller) {
      const client = new GeminiClient();
      
      await client.generateWithStreaming(prompt, (chunk) => {
        controller.enqueue(encoder.encode(`data: ${chunk}\n\n`));
      });
      
      controller.close();
    },
  });
  
  return new Response(stream, {
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
    },
  });
}
```

## Groq

### Setup

1. **Get API Key**
   - Go to [Groq Console](https://console.groq.com/keys)
   - Create new API key
   - Copy the key

2. **Add to Environment**
   ```env
   GROQ_API_KEY="gsk_..."
   GROQ_MODEL="llama3-70b-8192"
   ```

### Implementation

Create `lib/ai/groq.ts`:

```typescript
import Groq from 'groq-sdk';

const groq = new Groq({
  apiKey: process.env.GROQ_API_KEY,
});

export interface GroqConfig {
  model?: string;
  temperature?: number;
  maxTokens?: number;
  topP?: number;
}

export class GroqClient {
  private config: GroqConfig;
  
  constructor(config: GroqConfig = {}) {
    this.config = {
      model: config.model || 'llama3-70b-8192',
      temperature: config.temperature || 0.7,
      maxTokens: config.maxTokens || 8192,
      topP: config.topP || 1,
    };
  }
  
  async generateText(prompt: string): Promise<string> {
    try {
      const completion = await groq.chat.completions.create({
        messages: [{ role: 'user', content: prompt }],
        model: this.config.model!,
        temperature: this.config.temperature,
        max_tokens: this.config.maxTokens,
        top_p: this.config.topP,
      });
      
      return completion.choices[0]?.message?.content || '';
    } catch (error) {
      console.error('Groq API error:', error);
      throw new Error('Failed to generate text with Groq');
    }
  }
  
  async chat(messages: Array<{ role: string; content: string }>) {
    const completion = await groq.chat.completions.create({
      messages: messages as any,
      model: this.config.model!,
      temperature: this.config.temperature,
      max_tokens: this.config.maxTokens,
    });
    
    return {
      content: completion.choices[0]?.message?.content || '',
      tokensUsed: completion.usage?.total_tokens || 0,
    };
  }
  
  async generateWithStreaming(
    prompt: string,
    onChunk: (chunk: string) => void
  ): Promise<void> {
    const stream = await groq.chat.completions.create({
      messages: [{ role: 'user', content: prompt }],
      model: this.config.model!,
      temperature: this.config.temperature,
      stream: true,
    });
    
    for await (const chunk of stream) {
      const content = chunk.choices[0]?.delta?.content || '';
      if (content) {
        onChunk(content);
      }
    }
  }
}

// Available Groq models
export const GROQ_MODELS = {
  'llama3-70b': 'llama3-70b-8192',
  'llama3-8b': 'llama3-8b-8192',
  'mixtral-8x7b': 'mixtral-8x7b-32768',
  'gemma-7b': 'gemma-7b-it',
};

// Usage example
export async function generateWithGroq(prompt: string) {
  const client = new GroqClient({
    model: 'llama3-70b-8192',
    temperature: 0.7,
  });
  
  return await client.generateText(prompt);
}
```

### Speed Comparison

Groq is **10-100x faster** than other providers:

```typescript
// Benchmark different models
async function benchmarkModels(prompt: string) {
  const models = [
    { name: 'Groq Llama3', client: new GroqClient() },
    { name: 'Gemini Flash', client: new GeminiClient() },
    { name: 'GPT-3.5', client: new OpenAIClient() },
  ];
  
  for (const model of models) {
    const start = Date.now();
    await model.client.generateText(prompt);
    const duration = Date.now() - start;
    
    console.log(`${model.name}: ${duration}ms`);
  }
}

// Typical results:
// Groq Llama3: 250ms ⚡⚡⚡⚡
// Gemini Flash: 1200ms ⚡⚡⚡
// GPT-3.5: 2500ms ⚡⚡
```

## OpenAI

### Setup

```env
OPENAI_API_KEY="sk-..."
OPENAI_MODEL="gpt-4-turbo-preview"
```

### Implementation

Create `lib/ai/openai.ts`:

```typescript
import OpenAI from 'openai';

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

export class OpenAIClient {
  async generateText(prompt: string, model = 'gpt-4-turbo-preview') {
    const completion = await openai.chat.completions.create({
      messages: [{ role: 'user', content: prompt }],
      model,
      temperature: 0.7,
    });
    
    return completion.choices[0]?.message?.content || '';
  }
  
  async generateWithFunctions(
    prompt: string,
    functions: Array<any>
  ) {
    const completion = await openai.chat.completions.create({
      messages: [{ role: 'user', content: prompt }],
      model: 'gpt-4-turbo-preview',
      functions,
      function_call: 'auto',
    });
    
    return completion.choices[0];
  }
}
```

## Anthropic Claude

### Setup

```env
ANTHROPIC_API_KEY="sk-ant-..."
ANTHROPIC_MODEL="claude-3-opus-20240229"
```

### Implementation

Create `lib/ai/claude.ts`:

```typescript
import Anthropic from '@anthropic-ai/sdk';

const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
});

export class ClaudeClient {
  async generateText(prompt: string) {
    const message = await anthropic.messages.create({
      model: 'claude-3-opus-20240229',
      max_tokens: 4096,
      messages: [{ role: 'user', content: prompt }],
    });
    
    return message.content[0].text;
  }
}
```

## Model Context Protocol (MCP)

MCP enables AI models to interact with external tools and data sources.

### Setup MCP Server

Create `lib/mcp/server.ts`:

```typescript
import { MCPServer } from '@modelcontextprotocol/sdk';

export class AutomateAIMCPServer {
  private server: MCPServer;
  
  constructor() {
    this.server = new MCPServer({
      name: 'AutomateAI',
      version: '1.0.0',
    });
    
    this.registerTools();
  }
  
  private registerTools() {
    // Register workflow execution tool
    this.server.registerTool({
      name: 'execute_workflow',
      description: 'Execute an automation workflow',
      parameters: {
        type: 'object',
        properties: {
          workflowId: {
            type: 'string',
            description: 'ID of the workflow to execute',
          },
          input: {
            type: 'object',
            description: 'Input data for the workflow',
          },
        },
        required: ['workflowId'],
      },
      handler: async (params) => {
        return await this.executeWorkflow(params.workflowId, params.input);
      },
    });
    
    // Register data retrieval tool
    this.server.registerTool({
      name: 'query_database',
      description: 'Query the database for information',
      parameters: {
        type: 'object',
        properties: {
          query: {
            type: 'string',
            description: 'Natural language query',
          },
        },
        required: ['query'],
      },
      handler: async (params) => {
        return await this.queryDatabase(params.query);
      },
    });
    
    // Register document search tool
    this.server.registerTool({
      name: 'search_documents',
      description: 'Search documents using semantic search',
      parameters: {
        type: 'object',
        properties: {
          query: {
            type: 'string',
            description: 'Search query',
          },
          limit: {
            type: 'number',
            description: 'Number of results',
            default: 5,
          },
        },
        required: ['query'],
      },
      handler: async (params) => {
        return await this.searchDocuments(params.query, params.limit);
      },
    });
  }
  
  private async executeWorkflow(workflowId: string, input: any) {
    // Implementation
    return { status: 'success', result: {} };
  }
  
  private async queryDatabase(query: string) {
    // Convert natural language to SQL
    // Execute query
    // Return results
    return { results: [] };
  }
  
  private async searchDocuments(query: string, limit: number) {
    // Generate embedding for query
    // Search vector database
    // Return relevant documents
    return { documents: [] };
  }
  
  async start(port: number = 3001) {
    await this.server.listen(port);
    console.log(`MCP Server running on port ${port}`);
  }
}

// Start MCP server
if (require.main === module) {
  const server = new AutomateAIMCPServer();
  server.start();
}
```

### MCP Client Integration

Create `lib/mcp/client.ts`:

```typescript
import { MCPClient } from '@modelcontextprotocol/sdk';

export class MCPClientWrapper {
  private client: MCPClient;
  
  constructor() {
    this.client = new MCPClient({
      serverUrl: process.env.MCP_SERVER_URL || 'http://localhost:3001',
      apiKey: process.env.MCP_API_KEY,
    });
  }
  
  async executeWorkflow(workflowId: string, input: any) {
    return await this.client.callTool('execute_workflow', {
      workflowId,
      input,
    });
  }
  
  async queryDatabase(query: string) {
    return await this.client.callTool('query_database', { query });
  }
  
  async searchDocuments(query: string, limit: number = 5) {
    return await this.client.callTool('search_documents', { query, limit });
  }
}
```

### Using MCP with AI Models

```typescript
import { GeminiClient } from '@/lib/ai/gemini';
import { MCPClientWrapper } from '@/lib/mcp/client';

export async function aiWithTools(userPrompt: string) {
  const gemini = new GeminiClient();
  const mcp = new MCPClientWrapper();
  
  // First, let AI decide which tools to use
  const toolDecision = await gemini.generateText(`
    User request: ${userPrompt}
    
    Available tools:
    - execute_workflow: Run automation workflows
    - query_database: Query database
    - search_documents: Search knowledge base
    
    Which tools should be used? Respond with JSON.
  `);
  
  const tools = JSON.parse(toolDecision);
  
  // Execute tools
  const toolResults = await Promise.all(
    tools.map(async (tool: any) => {
      switch (tool.name) {
        case 'execute_workflow':
          return await mcp.executeWorkflow(tool.params.workflowId, tool.params.input);
        case 'query_database':
          return await mcp.queryDatabase(tool.params.query);
        case 'search_documents':
          return await mcp.searchDocuments(tool.params.query);
        default:
          return null;
      }
    })
  );
  
  // Generate final response with tool results
  const finalResponse = await gemini.generateText(`
    User request: ${userPrompt}
    Tool results: ${JSON.stringify(toolResults)}
    
    Generate a helpful response based on the tool results.
  `);
  
  return finalResponse;
}
```

## RAG Implementation

### Vector Embeddings

Create `lib/ai/embeddings.ts`:

```typescript
import { GoogleGenerativeAI } from '@google/generative-ai';
import { supabase } from '@/lib/supabase';

const genAI = new GoogleGenerativeAI(process.env.GOOGLE_GEMINI_API_KEY!);

export async function generateEmbedding(text: string): Promise<number[]> {
  const model = genAI.getGenerativeModel({ model: 'embedding-001' });
  const result = await model.embedContent(text);
  return result.embedding.values;
}

export async function storeDocument(
  userId: string,
  title: string,
  content: string,
  metadata?: any
) {
  // Generate embedding
  const embedding = await generateEmbedding(content);
  
  // Store in database
  const { data, error } = await supabase
    .from('documents')
    .insert({
      userId,
      title,
      content,
      metadata,
      embedding,
    })
    .select()
    .single();
  
  if (error) throw error;
  return data;
}

export async function searchSimilarDocuments(
  query: string,
  userId: string,
  limit: number = 5
) {
  // Generate query embedding
  const queryEmbedding = await generateEmbedding(query);
  
  // Search using cosine similarity
  const { data, error } = await supabase.rpc('match_documents', {
    query_embedding: queryEmbedding,
    match_threshold: 0.7,
    match_count: limit,
    user_id: userId,
  });
  
  if (error) throw error;
  return data;
}
```

### RAG Query Function

```typescript
export async function ragQuery(question: string, userId: string) {
  // 1. Search relevant documents
  const relevantDocs = await searchSimilarDocuments(question, userId);
  
  // 2. Build context from documents
  const context = relevantDocs
    .map((doc: any) => `${doc.title}\n${doc.content}`)
    .join('\n\n---\n\n');
  
  // 3. Generate answer with context
  const gemini = new GeminiClient();
  const answer = await gemini.generateText(`
    Context:
    ${context}
    
    Question: ${question}
    
    Answer the question based on the context provided. If the context doesn't contain relevant information, say so.
  `);
  
  return {
    answer,
    sources: relevantDocs.map((doc: any) => ({
      title: doc.title,
      similarity: doc.similarity,
    })),
  };
}
```

## Best Practices

### 1. Error Handling

```typescript
async function safeAICall<T>(
  fn: () => Promise<T>,
  fallback: T
): Promise<T> {
  try {
    return await fn();
  } catch (error) {
    console.error('AI API error:', error);
    return fallback;
  }
}

// Usage
const response = await safeAICall(
  () => gemini.generateText(prompt),
  'Sorry, I encountered an error.'
);
```

### 2. Rate Limiting

```typescript
import { Ratelimit } from '@upstash/ratelimit';
import { Redis } from '@upstash/redis';

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(10, '1 m'),
});

export async function checkRateLimit(userId: string) {
  const { success } = await ratelimit.limit(userId);
  if (!success) {
    throw new Error('Rate limit exceeded');
  }
}
```

### 3. Cost Tracking

```typescript
export async function trackAIUsage(
  userId: string,
  provider: string,
  tokensUsed: number
) {
  const cost = calculateCost(provider, tokensUsed);
  
  await prisma.usageLog.create({
    data: {
      userId,
      resourceType: 'ai_request',
      action: provider,
      metadata: {
        tokensUsed,
        cost,
      },
    },
  });
}

function calculateCost(provider: string, tokens: number): number {
  const pricing = {
    gemini: 0.00001, // $0.01 per 1K tokens
    groq: 0.00001,
    openai: 0.00003,
    claude: 0.00008,
  };
  
  return (tokens / 1000) * (pricing[provider] || 0);
}
```

### 4. Caching

```typescript
import { Redis } from '@upstash/redis';

const redis = Redis.fromEnv();

export async function cachedAICall(
  key: string,
  fn: () => Promise<string>,
  ttl: number = 3600
): Promise<string> {
  // Check cache
  const cached = await redis.get(key);
  if (cached) return cached as string;
  
  // Generate and cache
  const result = await fn();
  await redis.set(key, result, { ex: ttl });
  
  return result;
}

// Usage
const response = await cachedAICall(
  `ai:${userId}:${prompt}`,
  () => gemini.generateText(prompt)
);
```

### 5. Prompt Templates

```typescript
export const PROMPT_TEMPLATES = {
  summarize: (text: string) => `
    Summarize the following text in 2-3 sentences:
    
    ${text}
  `,
  
  translate: (text: string, language: string) => `
    Translate the following text to ${language}:
    
    ${text}
  `,
  
  codeReview: (code: string) => `
    Review this code and provide feedback:
    
    \`\`\`
    ${code}
    \`\`\`
    
    Focus on:
    - Code quality
    - Best practices
    - Potential bugs
    - Performance
  `,
};
```

## Resources

- [Google Gemini Docs](https://ai.google.dev/docs)
- [Groq Documentation](https://console.groq.com/docs)
- [OpenAI API Reference](https://platform.openai.com/docs)
- [Anthropic Claude Docs](https://docs.anthropic.com)
- [MCP Specification](https://modelcontextprotocol.io)

---

**Need help?** Open an issue on [GitHub](https://github.com/itskiranbabu/automate-ai-saas/issues)

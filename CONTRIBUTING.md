# Contributing to AutomateAI

Thank you for your interest in contributing to AutomateAI! This document provides guidelines and instructions for contributing.

## Code of Conduct

By participating in this project, you agree to abide by our Code of Conduct:

- Be respectful and inclusive
- Welcome newcomers
- Focus on constructive feedback
- Respect differing viewpoints

## How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported in [Issues](https://github.com/itskiranbabu/automate-ai-saas/issues)
2. If not, create a new issue with:
   - Clear title and description
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots if applicable
   - Environment details (OS, browser, Node version)

### Suggesting Features

1. Check [Issues](https://github.com/itskiranbabu/automate-ai-saas/issues) for existing feature requests
2. Create a new issue with:
   - Clear description of the feature
   - Use cases and benefits
   - Possible implementation approach

### Pull Requests

1. **Fork the repository**
   ```bash
   git clone https://github.com/itskiranbabu/automate-ai-saas.git
   cd automate-ai-saas
   ```

2. **Create a branch**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

3. **Make your changes**
   - Follow the code style guidelines
   - Write clear commit messages
   - Add tests if applicable
   - Update documentation

4. **Test your changes**
   ```bash
   npm run lint
   npm run type-check
   npm run test
   npm run build
   ```

5. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add new feature"
   # or
   git commit -m "fix: resolve bug"
   ```

   Follow [Conventional Commits](https://www.conventionalcommits.org/):
   - `feat:` New feature
   - `fix:` Bug fix
   - `docs:` Documentation changes
   - `style:` Code style changes
   - `refactor:` Code refactoring
   - `test:` Test changes
   - `chore:` Build/config changes

6. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Create Pull Request**
   - Go to the original repository
   - Click "New Pull Request"
   - Select your branch
   - Fill in the PR template
   - Link related issues

## Development Setup

### Prerequisites

- Node.js 20+
- npm 10+
- Git
- Supabase account
- Clerk account
- Stripe account

### Installation

```bash
# Clone repository
git clone https://github.com/itskiranbabu/automate-ai-saas.git
cd automate-ai-saas

# Install dependencies
npm install

# Copy environment variables
cp .env.example .env.local

# Set up database
npm run db:migrate
npm run db:seed

# Start development server
npm run dev
```

### Project Structure

```
automate-ai-saas/
├── app/              # Next.js app directory
├── components/       # React components
├── lib/              # Utility functions
├── prisma/           # Database schema
├── docs/             # Documentation
└── public/           # Static assets
```

## Code Style Guidelines

### TypeScript

- Use TypeScript for all new code
- Define proper types and interfaces
- Avoid `any` type
- Use meaningful variable names

```typescript
// ✅ Good
interface User {
  id: string;
  email: string;
  name: string;
}

async function getUser(userId: string): Promise<User> {
  // ...
}

// ❌ Bad
async function getUser(id: any): Promise<any> {
  // ...
}
```

### React Components

- Use functional components with hooks
- Keep components small and focused
- Use proper prop types
- Add JSDoc comments for complex components

```typescript
// ✅ Good
interface ButtonProps {
  label: string;
  onClick: () => void;
  variant?: 'primary' | 'secondary';
}

export function Button({ label, onClick, variant = 'primary' }: ButtonProps) {
  return (
    <button onClick={onClick} className={`btn-${variant}`}>
      {label}
    </button>
  );
}

// ❌ Bad
export function Button(props: any) {
  return <button onClick={props.onClick}>{props.label}</button>;
}
```

### File Naming

- Components: `PascalCase.tsx`
- Utilities: `camelCase.ts`
- Constants: `UPPER_SNAKE_CASE.ts`
- Types: `types.ts` or `*.types.ts`

### Imports

- Group imports logically
- Use absolute imports with `@/` prefix

```typescript
// ✅ Good
import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { getUser } from '@/lib/api';
import type { User } from '@/types';

// ❌ Bad
import { Button } from '../../../components/ui/button';
import { getUser } from '../../../lib/api';
```

## Testing

### Writing Tests

```typescript
import { render, screen } from '@testing-library/react';
import { Button } from './Button';

describe('Button', () => {
  it('renders with label', () => {
    render(<Button label="Click me" onClick={() => {}} />);
    expect(screen.getByText('Click me')).toBeInTheDocument();
  });

  it('calls onClick when clicked', () => {
    const handleClick = jest.fn();
    render(<Button label="Click me" onClick={handleClick} />);
    screen.getByText('Click me').click();
    expect(handleClick).toHaveBeenCalledTimes(1);
  });
});
```

### Running Tests

```bash
# Run all tests
npm run test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:coverage
```

## Documentation

- Update README.md for major changes
- Add JSDoc comments for functions
- Update relevant docs in `/docs` folder
- Include examples in documentation

## Review Process

1. **Automated Checks**
   - Linting
   - Type checking
   - Tests
   - Build

2. **Code Review**
   - At least one approval required
   - Address all comments
   - Keep discussions constructive

3. **Merge**
   - Squash and merge
   - Delete branch after merge

## Release Process

1. Update version in `package.json`
2. Update CHANGELOG.md
3. Create release tag
4. Deploy to production

## Getting Help

- 💬 [Discord Community](https://discord.gg/automateai)
- 📧 Email: support@automateai.com
- 📖 [Documentation](https://docs.automateai.com)
- 🐛 [Issue Tracker](https://github.com/itskiranbabu/automate-ai-saas/issues)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing to AutomateAI! 🚀**

# Contributing to API Generic Consumer Frontend

Thank you for your interest in contributing to the API Generic Consumer Frontend! This document provides comprehensive guidelines to help you contribute effectively in our open source project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Documentation](#documentation)
- [Pull Request Process](#pull-request-process)
- [Issue Reporting](#issue-reporting)
- [Security](#security)

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). Please read and follow it in all your interactions with the project.

## Getting Started

### Prerequisites

- Node.js 20 or higher
- npm or yarn
- Git
- Modern web browser
- IDE (VS Code recommended)

### Setup

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/your-username/api-generic-consumer-frontend.git
   cd api-generic-consumer-frontend
   ```
3. Add the original repository as upstream:
   ```bash
   git remote add upstream https://github.com/original-owner/api-generic-consumer-frontend.git
   ```
4. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Workflow

We follow the GitFlow branching model:

### Branch Structure

- `main`: Production-ready code
- `develop`: Integration branch for features
- `feature/*`: New features
- `release/*`: Release preparation
- `hotfix/*`: Critical fixes

### Workflow

1. **Create Feature Branch**
   ```bash
   git checkout develop
   git pull upstream develop
   git checkout -b feature/your-feature-name
   ```

2. **Develop and Test**
   - Write code following our coding standards
   - Add comprehensive tests
   - Ensure all tests pass

3. **Commit Changes**
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```

4. **Push and Create PR**
   ```bash
   git push origin feature/your-feature-name
   ```

## Coding Standards

### TypeScript/JavaScript Guidelines

- Follow [TypeScript style guide](https://typescript-eslint.io/)
- Use meaningful variable and function names
- Keep functions small and focused
- Add JSDoc comments for public APIs
- Use modern ES6+ features

### Code Style

```typescript
// Good
const getUserById = async (id: string): Promise<User> => {
  const user = await userRepository.findById(id);
  if (!user) {
    throw new Error(`User with id ${id} not found`);
  }
  return user;
};

// Bad
const getUser = async (id) => {
  const u = await userRepository.findById(id);
  return u;
};
```

### React Guidelines

- Use functional components with hooks
- Follow React best practices
- Implement proper error boundaries
- Use TypeScript for type safety
- Follow accessibility guidelines

### Architecture Guidelines

- Follow clean architecture principles
- Use proper state management
- Implement proper error handling
- Separate concerns properly

## Testing Guidelines

### Test Structure

```
src/
├── __tests__/
│   ├── unit/           # Unit tests
│   ├── integration/    # Integration tests
│   └── e2e/           # End-to-end tests
└── components/
    └── __tests__/       # Component tests
```

### Writing Tests

```typescript
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { UserCard } from './UserCard';

describe('UserCard', () => {
  const mockUser = {
    id: '1',
    name: 'John Doe',
    email: 'john@example.com'
  };

  it('should render user information correctly', () => {
    render(<UserCard user={mockUser} />);
    
    expect(screen.getByText('John Doe')).toBeInTheDocument();
    expect(screen.getByText('john@example.com')).toBeInTheDocument();
  });

  it('should handle click events', async () => {
    const onEdit = jest.fn();
    render(<UserCard user={mockUser} onEdit={onEdit} />);
    
    const editButton = screen.getByRole('button', { name: /edit/i });
    await userEvent.click(editButton);
    
    expect(onEdit).toHaveBeenCalledWith(mockUser);
  });
});
```

### Test Coverage

- Maintain minimum 80% code coverage
- Write tests for critical user flows
- Test edge cases and error scenarios
- Use meaningful test names

## Documentation

### Code Documentation

- Add JSDoc for all public functions
- Document complex business logic
- Include examples in documentation

### README Updates

Update README.md for:
- New features
- Configuration changes
- API modifications
- Setup instructions

## Pull Request Process

### Before Submitting

1. **Code Quality**
   - [ ] Code follows style guidelines
   - [ ] Tests pass locally
   - [ ] Documentation is updated
   - [ ] No sensitive data in code

2. **Testing**
   - [ ] Unit tests written
   - [ ] Integration tests pass
   - [ ] Manual testing completed
   - [ ] Accessibility checks passed

3. **Security**
   - [ ] No hardcoded secrets
   - [ ] Input validation implemented
   - [ ] XSS prevention considered
   - [ ] Authentication/authorization considered

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] E2E tests pass
- [ ] Manual testing completed

## Accessibility
- [ ] Screen reader compatible
- [ ] Keyboard navigation works
- [ ] Color contrast compliant

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes (or documented)
```

### Review Process

1. Automated checks must pass
2. At least one maintainer approval required
3. Address all review comments
4. Maintain clean commit history

## Issue Reporting

### Bug Reports

Use the following template for bug reports:

```markdown
**Bug Description**
Clear description of the bug

**Steps to Reproduce**
1. Step 1
2. Step 2
3. Step 3

**Expected Behavior**
What should happen

**Actual Behavior**
What actually happens

**Environment**
- OS: [e.g., Windows 10, macOS 12.0]
- Browser: [e.g., Chrome 120, Firefox 121]
- Node Version: [e.g., 20.10.0]

**Additional Context**
Any other relevant information
- Screenshots if applicable
```

### Feature Requests

```markdown
**Feature Description**
Clear description of the feature

**Problem Statement**
What problem does this solve?

**Proposed Solution**
How should this be implemented?

**Alternatives Considered**
Other approaches you thought about

**Additional Context**
Any other relevant information
- Mockups if applicable
```

## Security

If you discover a security vulnerability, please report it privately to:

- Email: security@example.com
- Do not open a public issue

See our [Security Policy](SECURITY.md) for more details.

## Getting Help

- Check existing issues and documentation
- Join our [Discord community](https://discord.gg/example)
- Create an issue for questions

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
7. Push para sua branch
8. Abra um Pull Request

## 🔄 Processo de Desenvolvimento

### Setup do Ambiente

```bash
# Clone seu fork
git clone https://github.com/seu-usuario/api-generic-consumer-frontend.git
cd api-generic-consumer-frontend

# Adicione o repositório upstream
git remote add upstream https://github.com/original-org/api-generic-consumer-frontend.git

# Instale dependências
npm install

# Execute em modo desenvolvimento
npm run dev
```

### Workflow de Branches

Usamos o modelo de branching simplificado:

- `main`: Branch principal, sempre estável
- `feature/*`: Novas funcionalidades
- `fix/*`: Correções de bugs
- `docs/*`: Atualizações de documentação
- `refactor/*`: Refatorações de código

```bash
# Criar nova branch
git checkout -b feature/minha-feature

# Manter branch atualizada
git fetch upstream
git rebase upstream/main
```

## 📝 Padrões de Código

### TypeScript/React Style Guide

Seguimos as melhores práticas de TypeScript e React:

```typescript
// ✅ BOM - Componente funcional com TypeScript
interface ButtonProps {
  label: string;
  onClick: () => void;
  variant?: 'primary' | 'secondary';
}

export function Button({ label, onClick, variant = 'primary' }: ButtonProps) {
  return (
    <button
      onClick={onClick}
      className={`btn btn-${variant}`}
    >
      {label}
    </button>
  );
}

// ❌ RUIM - Sem tipos, props desestruturadas incorretamente
export function Button(props) {
  return <button onClick={props.onClick}>{props.label}</button>;
}
```

### Regras Gerais

- **Indentação**: 2 espaços (não tabs)
- **Linha máxima**: 100 caracteres
- **Nomenclatura**:
  - Componentes: `PascalCase`
  - Funções/Variáveis: `camelCase`
  - Constantes: `UPPER_SNAKE_CASE`
  - Arquivos: `kebab-case.tsx` ou `PascalCase.tsx` (componentes)

### Estrutura de Componentes

```typescript
// 1. Imports
import { useState } from 'react';
import { Button } from '@/components/ui/Button';

// 2. Types/Interfaces
interface MyComponentProps {
  title: string;
}

// 3. Component
export function MyComponent({ title }: MyComponentProps) {
  // 3.1. Hooks
  const [count, setCount] = useState(0);
  
  // 3.2. Handlers
  const handleClick = () => {
    setCount(prev => prev + 1);
  };
  
  // 3.3. Render
  return (
    <div>
      <h1>{title}</h1>
      <Button label={`Count: ${count}`} onClick={handleClick} />
    </div>
  );
}
```

### Hooks Customizados

```typescript
// ✅ BOM
export function useCounter(initialValue = 0) {
  const [count, setCount] = useState(initialValue);
  
  const increment = () => setCount(prev => prev + 1);
  const decrement = () => setCount(prev => prev - 1);
  const reset = () => setCount(initialValue);
  
  return { count, increment, decrement, reset };
}

// Uso
const { count, increment } = useCounter(10);
```

### Tailwind CSS

```typescript
// ✅ BOM - Classes organizadas e legíveis
<div className="flex items-center justify-between p-4 bg-white rounded-lg shadow-md">
  <h2 className="text-xl font-bold text-gray-800">Title</h2>
  <button className="px-4 py-2 text-white bg-blue-500 rounded hover:bg-blue-600">
    Click
  </button>
</div>

// ❌ RUIM - Classes desorganizadas
<div className="p-4 flex bg-white items-center rounded-lg justify-between shadow-md">
```

## 💬 Padrões de Commit

Usamos [Conventional Commits](https://www.conventionalcommits.org/):

### Formato

```
<tipo>(<escopo>): <descrição>

[corpo opcional]

[rodapé opcional]
```

### Tipos

- `feat`: Nova funcionalidade
- `fix`: Correção de bug
- `docs`: Documentação
- `style`: Formatação (não afeta código)
- `refactor`: Refatoração
- `test`: Adição/correção de testes
- `chore`: Manutenção/tarefas
- `perf`: Melhoria de performance

### Exemplos

```bash
# Feature
feat(api-tester): add support for file upload

# Bug fix
fix(session): correct timestamp format in audit log

# Documentation
docs(readme): update installation instructions

# Refactoring
refactor(components): extract common button logic

# Breaking change
feat(auth)!: change authentication flow to use MSAL

BREAKING CHANGE: Authentication now requires Azure AD configuration
```

## 🔀 Pull Requests

### Checklist

Antes de submeter um PR, verifique:

- [ ] Código segue os padrões do projeto
- [ ] Testes adicionados/atualizados
- [ ] Todos os testes passam
- [ ] Documentação atualizada
- [ ] Commits seguem padrão conventional
- [ ] Branch está atualizada com main
- [ ] Sem conflitos de merge
- [ ] Build passa sem warnings

### Template de PR

```markdown
## Descrição
Breve descrição das mudanças

## Tipo de Mudança
- [ ] Bug fix
- [ ] Nova feature
- [ ] Breaking change
- [ ] Documentação

## Como Testar
1. Passo 1
2. Passo 2
3. Resultado esperado

## Screenshots
(se aplicável)

## Checklist
- [ ] Testes passando
- [ ] Documentação atualizada
- [ ] Code review solicitado

## Issues Relacionadas
Closes #123
```

### Processo de Review

1. Pelo menos 1 aprovação necessária
2. CI deve passar
3. Sem conflitos
4. Cobertura de testes mantida

## 🧪 Testes

### Estrutura de Testes

```typescript
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from './Button';

describe('Button', () => {
  it('should render with label', () => {
    render(<Button label="Click me" onClick={() => {}} />);
    expect(screen.getByText('Click me')).toBeInTheDocument();
  });

  it('should call onClick when clicked', () => {
    const handleClick = jest.fn();
    render(<Button label="Click" onClick={handleClick} />);
    
    fireEvent.click(screen.getByText('Click'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });
});
```

### Executando Testes

```bash
# Todos os testes
npm test

# Watch mode
npm test -- --watch

# Com cobertura
npm test -- --coverage

# Testes específicos
npm test Button.test.tsx
```

## 🎨 Design System

### Cores

```typescript
// Usar variáveis do Tailwind
const colors = {
  primary: 'blue-500',
  secondary: 'gray-500',
  success: 'green-500',
  danger: 'red-500',
  warning: 'yellow-500',
};
```

### Componentes UI

Sempre use componentes do diretório `components/ui/`:

```typescript
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Select } from '@/components/ui/Select';
```

## 📚 Recursos Adicionais

- [Next.js Documentation](https://nextjs.org/docs)
- [React Documentation](https://react.dev/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Tailwind CSS](https://tailwindcss.com/docs)
- [Testing Library](https://testing-library.com/docs/react-testing-library/intro/)

## ❓ Dúvidas?

- Abra uma [Discussion](https://github.com/org/repo/discussions)
- Entre em contato via email: dev@example.com
- Consulte a [documentação](docs/)

## 🙏 Agradecimentos

Obrigado por contribuir! Sua ajuda torna este projeto melhor para todos. 🚀

---

**Lembre-se**: Código é lido muito mais vezes do que escrito. Escreva pensando em quem vai ler!
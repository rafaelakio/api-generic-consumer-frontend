# Guia de Contribuição

Obrigado por considerar contribuir com o API Generic Consumer Frontend! 🎉

## 📋 Índice

- [Código de Conduta](#código-de-conduta)
- [Como Posso Contribuir?](#como-posso-contribuir)
- [Processo de Desenvolvimento](#processo-de-desenvolvimento)
- [Padrões de Código](#padrões-de-código)
- [Padrões de Commit](#padrões-de-commit)
- [Pull Requests](#pull-requests)
- [Testes](#testes)

## 📜 Código de Conduta

Este projeto adere ao [Código de Conduta](CODE_OF_CONDUCT.md). Ao participar, você concorda em manter este código.

## 🤝 Como Posso Contribuir?

### Reportando Bugs

Antes de criar um bug report, verifique se o problema já não foi reportado. Se você encontrar um bug:

1. Use o template de issue para bugs
2. Inclua título claro e descritivo
3. Descreva os passos para reproduzir
4. Forneça exemplos específicos
5. Descreva o comportamento esperado vs atual
6. Inclua screenshots se aplicável
7. Adicione informações do ambiente (Browser, OS, Node version)

### Sugerindo Melhorias

Para sugerir melhorias:

1. Use o template de issue para features
2. Explique claramente o problema que a feature resolve
3. Descreva a solução proposta
4. Liste alternativas consideradas
5. Adicione mockups se aplicável

### Contribuindo com Código

1. Fork o repositório
2. Crie uma branch para sua feature
3. Faça suas alterações
4. Adicione testes
5. Garanta que todos os testes passam
6. Faça commit das suas mudanças
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
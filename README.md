# Desafio técnico e-commerce

## 📋 **Funcionalidades Implementadas**

### **🛒 Carrinho de Compras**
- ✅ **Adicionar produtos** - POST `/cart`
- ✅ **Listar carrinho** - GET `/cart`
- ✅ **Alterar quantidade** - POST `/cart/add_item`
- ✅ **Remover produtos** - DELETE `/cart/:product_id`
- ✅ **Sessão automática** - Gerenciamento de carrinhos por sessão
- ✅ **Validações** - Quantidade positiva, produto existente
- ✅ **Cálculos automáticos** - Total do carrinho e preços unitários

### **⏰ Sistema de Abandono**
- ✅ **Job automático** - `MarkCartAsAbandonedJob`
- ✅ **Marcação automática** - Carrinhos inativos por 3+ horas
- ✅ **Remoção automática** - Carrinhos abandonados por 7+ dias
- ✅ **Configuração Sidekiq** - Execução a cada hora

### **🧪 Testes**
- ✅ **Factories** - Product, Cart, CartItem com traits
- ✅ **Testes de modelo** - Validações, associações, métodos
- ✅ **Testes de controller** - Todos os endpoints
- ✅ **Testes de job** - Funcionalidade de abandono
- ✅ **Cobertura completa** - 64 testes passando

## 🚀 **Como Executar**

### **Opção 1: Docker (Recomendado)**

```bash
# Construir e iniciar todos os serviços
docker-compose up --build

# Em terminais separados:
# Terminal 1: Servidor Rails (porta 3000)
docker-compose up web

# Terminal 2: Sidekiq (para jobs)
docker-compose up sidekiq

# Terminal 3: Executar testes
docker-compose run test
```

### **Opção 2: Local (Requisitos)**

```bash
# Instalar dependências
bundle install

# Configurar banco de dados
bundle exec rails db:create
bundle exec rails db:migrate

# Executar REDIS (em outro terminal)
redis-server

# Executar servidor Rails
bundle exec rails server

# Executar Sidekiq (em outro terminal)
bundle exec sidekiq

# Executar testes
bundle exec rspec
```

## 📡 **Endpoints da API**

### **Carrinho de Compras**

#### **Adicionar Produto**
```http
POST /cart
Content-Type: application/json

{
  "product_id": 1,
  "quantity": 2
}
```

#### **Listar Carrinho**
```http
GET /cart
```

#### **Alterar Quantidade**
```http
POST /cart/add_item
Content-Type: application/json

{
  "product_id": 1,
  "quantity": 3
}
```

#### **Remover Produto**
```http
DELETE /cart/1
```

### **Resposta Padrão**
```json
{
  "id": 1,
  "products": [
    {
      "id": 1,
      "name": "Produto Teste",
      "quantity": 2,
      "unit_price": 10.0,
      "total_price": 20.0
    }
  ],
  "total_price": 20.0
}
```

## 🛠️ **Tecnologias Utilizadas**

- **Ruby 3.3.1**
- **Rails 7.1.3.2**
- **PostgreSQL 16**
- **Redis 7.0.15**
- **Sidekiq** - Para jobs em background
- **RSpec** - Para testes
- **FactoryBot** - Para factories de teste
- **Shoulda Matchers** - Para testes de associação/validação

## 📊 **Estrutura do Projeto**

```
app/
├── controllers/
│   ├── carts_controller.rb      # API do carrinho
│   └── products_controller.rb   # CRUD de produtos
├── models/
│   ├── cart.rb                  # Modelo do carrinho
│   ├── cart_item.rb             # Itens do carrinho
│   └── product.rb               # Modelo de produto
├── sidekiq/
│   └── mark_cart_as_abandoned_job.rb  # Job de abandono
└── services/
    └── cart_service.rb          # Lógica de negócio

spec/
├── factories/                   # Factories para testes
├── models/                      # Testes de modelo
├── requests/                    # Testes de API
└── sidekiq/                     # Testes de jobs
```

## 🔧 **Configurações**

### **Banco de Dados**
- **Desenvolvimento**: `store_development`
- **Teste**: `store_test`
- **Configuração**: `config/database.yml`

### **Sidekiq**
- **Configuração**: `config/sidekiq.yml`
- **Job de abandono**: Executa a cada hora
- **Interface web**: Disponível em `/sidekiq`

### **Variáveis de Ambiente**
```bash
DATABASE_URL=postgresql://postgres:password@localhost:5432/store_development
REDIS_URL=redis://localhost:6379/0
RAILS_ENV=development
```

## 🧪 **Executando Testes**

```bash
# Todos os testes
bundle exec rspec

# Testes específicos
bundle exec rspec spec/models/
bundle exec rspec spec/requests/
bundle exec rspec spec/sidekiq/

# Com cobertura
bundle exec rspec --format documentation
```

## 📝 **Decisões Técnicas**

### **Arquitetura**
- **Controllers**: Focados em receber requisições e retornar respostas
- **Models**: Contêm validações e lógica de negócio
- **Jobs**: Para processamento assíncrono (carrinhos abandonados)

### **Sessão**
- **Gerenciamento**: Automático via `session[:cart_id]`
- **Criação**: Novo carrinho quando necessário
- **Abandono**: Carrinhos abandonados são ignorados

### **Validações**
- **Quantidade**: Deve ser maior que 0
- **Produto**: Deve existir no banco
- **Unicidade**: Um produto por carrinho (quantidade somada)

## 🚀 **Próximos Passos (Melhorias Futuras)**

- [ ] **Cache** - Redis para melhor performance
- [ ] **Logs estruturados** - Para monitoramento
- [ ] **Documentação API** - Swagger/OpenAPI
- [ ] **Testes de integração** - Mais abrangentes
- [ ] **Monitoramento** - Métricas de carrinhos abandonados
- [ ] **Notificações** - Email para carrinhos abandonados

---

**Desenvolvido para o teste técnico da RD Station** 🚀

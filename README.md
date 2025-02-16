## DESAFIO CLEAN ARCHITECTURE ##

# DESCRIÇÃO DO PROJETO #

Olá devs!
Agora é a hora de botar a mão na massa. Para este desafio, você precisará criar o usecase de listagem das orders.
Esta listagem precisa ser feita com:
- Endpoint REST (GET /order)
- Service ListOrders com GRPC
- Query ListOrders GraphQL
Não esqueça de criar as migrações necessárias e o arquivo api.http com a request para criar e listar as orders.

Para a criação do banco de dados, utilize o Docker (Dockerfile / docker-compose.yaml), com isso ao rodar o comando docker compose up tudo deverá subir, preparando o banco de dados.
Inclua um README.md com os passos a serem executados no desafio e a porta em que a aplicação deverá responder em cada serviço.

# PASSO-A-PASSO PARA EXECUÇÃO DO PROJETO #

# [1] DOCKER #

1- Start docker.

2- sh: docker-compose up -d

# [2] RABBITMQ #

1- Access http://localhost:15672

2- Create a new queue: orders

3- Create a new binding: amq.direct

# [3] MIGRATION #

1- sh: migrate -path=sql/migrations -database "mysql://root:root@tcp(localhost:3306)/orders" -verbose up

# [4] APPLICATION #

1- sh: cd cmd/ordersystem

2- sh: go run main.go wire_gen.go

# [5] API REST #

1- Create order: api/create_order.http

2- List orders: api/list_orders.http

# [6] GRAPHQL #

1- Create order:
mutation {
  createOrder(input: {
    id: "b",
    Price: 200.5,
    Tax: 1.5
  }) {
    id
    Price
    Tax
    FinalPrice
  }
}

2- List orders:
query {
  listOrders {
    id
    Price
    Tax
    FinalPrice
  }
}

# [7] GRPC #

1- sh: evans -r repl

2- call CreateOrder

3- call ListOrders


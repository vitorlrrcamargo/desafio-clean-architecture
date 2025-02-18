# Etapa 1: Baixar a imagem base do Go
FROM golang:1.22.5 as builder

# Definir o diretório de trabalho no container
WORKDIR /app

# Copiar o código-fonte da aplicação
COPY . .

# Definir as variáveis de ambiente para garantir a compilação correta
ENV GOARCH=amd64
ENV GOOS=linux

# Baixar as dependências e compilar a aplicação
RUN go mod tidy
RUN go build -o ordersystem cmd/ordersystem/main.go cmd/ordersystem/wire_gen.go

# Etapa 2: Imagem final
FROM alpine:latest

# Instalar dependências necessárias: wget e migrate
RUN apk update && apk add --no-cache wget
RUN apk add --no-cache libc6-compat 

# Baixar o migrate e extrair
RUN wget https://github.com/golang-migrate/migrate/releases/download/v4.14.1/migrate.linux-amd64.tar.gz \
    && tar -xvzf migrate.linux-amd64.tar.gz \
    && ls -alh  # Listar os arquivos extraídos

# Verificar se o arquivo "migrate" foi extraído e movê-lo para o local correto
RUN mv migrate.linux-amd64 /usr/local/bin/migrate && rm migrate.linux-amd64.tar.gz

# Copiar a aplicação compilada para o container
COPY --from=builder /app/ordersystem /usr/local/bin/ordersystem
COPY --from=builder /app/cmd/ordersystem/.env /usr/local/bin/.env

# Copiar a pasta de migrações para o container
COPY --from=builder /app/sql /app/sql

# Garantir que o arquivo executável tenha permissão de execução
RUN chmod +x /usr/local/bin/ordersystem

# Definir o diretório de trabalho
WORKDIR /usr/local/bin

# Expor as portas necessárias
EXPOSE 8000
EXPOSE 8080
EXPOSE 50051

# Comando para rodar a migração
CMD ["sh", "-c", "migrate -path=/app/sql/migrations -database 'mysql://root:root@tcp(mysql:3306)/orders' -verbose up && ordersystem"]

# Estágio 1: Build da aplicação com Gradle
FROM gradle:8.5.0-jdk17-alpine AS builder

WORKDIR /app
COPY build.gradle settings.gradle gradlew ./
COPY gradle ./gradle
COPY src ./src

# Garante que o gradlew é executável e faz o build
RUN chmod +x ./gradlew && ./gradlew build --no-daemon

# Estágio 2: Criação da imagem final, apenas com o JRE e o .jar
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Copia o .jar do estágio de build para a imagem final
COPY --from=builder /app/build/libs/*.jar app.jar

# Expõe a porta padrão do Spring Boot (8080)
EXPOSE 8080

# Comando para executar a aplicação
ENTRYPOINT ["java", "-jar", "app.jar"]

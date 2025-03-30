# Build stage
FROM eclipse-temurin:17-jdk AS builder

WORKDIR /workspace/app

COPY .mvn .mvn
COPY mvnw .
COPY pom.xml .

# Install dependencies
RUN ./mvnw dependency:go-offline

COPY src src

# Build the application
RUN ./mvnw clean package -DskipTests

# -----------------------------------------------------------------------------
# Runtime stage
# -----------------------------------------------------------------------------
FROM eclipse-temurin:17-jre-ubi9-minimal
WORKDIR /app

ARG APP_NAME
ARG APP_VERSION

# Application metadata
LABEL maintainer="Quentin Vu <quentindevops@gmail.com>" \
      app.name=${APP_NAME} \
      app.version=${APP_VERSION}

# Copy JAR from builder stage
COPY --from=builder /workspace/app/target/*.jar app.jar

ENV SERVER_PORT=8081 \
    DATABASE_PORT=27017 \
    MONGODB_URI=

# Set environment variables
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

# Expose port
EXPOSE ${SERVER_PORT}
EXPOSE ${DATABASE_PORT}

ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -jar app.jar"]
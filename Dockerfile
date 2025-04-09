# Build stage
FROM eclipse-temurin:17-jdk AS builder

WORKDIR /workspace/app

COPY .mvn .mvn
COPY mvnw .
COPY pom.xml .

# Fix permissions and install dependencies
RUN chmod +x ./mvnw && \
    ./mvnw dependency:go-offline

COPY src src

# Build the application
RUN ./mvnw clean package -DskipTests

# -----------------------------------------------------------------------------
# Runtime stage
# -----------------------------------------------------------------------------
FROM eclipse-temurin:17-jre-ubi9-minimal
WORKDIR /app

# Copy JAR from builder stage
COPY --from=builder /workspace/app/target/*.jar app.jar

ENV SERVER_PORT=8081 \
    DATABASE_PORT=27017 \
    MONGODB_HOST=mongodb \
    MONGODB_PORT=27017 \
    MONGODB_DATABASE=mock-project \
    MONGODB_USERNAME=admin \
    MONGODB_PASSWORD=password

# Set environment variables
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

# Expose port
EXPOSE ${SERVER_PORT}

ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -jar app.jar"]
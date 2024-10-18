# Stage 1: Build the application
FROM node:14-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Stage 2: Create the production image
FROM node:14-alpine

# Set working directory
WORKDIR /app

# Copy built assets from the builder stage
COPY --from=builder /app .

# Create a non-root user
RUN adduser -D appuser
USER appuser

# Expose the port the app runs on
EXPOSE 3000

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000

# Define a volume for logs
VOLUME /app/logs

# Healthcheck to verify the application is running
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget -q -O - http://localhost:3000 || exit 1

# Command to run the application
CMD ["npm", "start"]

# Build-time arguments
ARG BUILD_VERSION
LABEL version=$BUILD_VERSION

# Example of using build cache mount for faster builds
# Only works with Docker BuildKit enabled
# RUN --mount=type=cache,target=/app/node_modules npm install

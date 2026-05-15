# AI-generated Dockerfile
FROM node:20

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application code
COPY . .

# Build TypeScript
RUN npm run build

# Copy ML model
COPY models ./models

# Expose port
EXPOSE 8080

# Start application
CMD ["node", "dist/server.js"]
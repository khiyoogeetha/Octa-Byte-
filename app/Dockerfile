# Stage 1: Build & Dependencies
FROM node:18-alpine AS builder

WORKDIR /usr/src/app

# Copy package.json and package-lock.json (if available)
COPY package*.json ./

# Install production dependencies only to keep the image lightweight
RUN npm ci --only=production || npm install --only=production

# Stage 2: Production runtime image
FROM node:18-alpine

# Use non-root user for security (comes pre-created in node image)
USER node

WORKDIR /usr/src/app

# Copy dependencies from builder
COPY --chown=node:node --from=builder /usr/src/app/node_modules ./node_modules

# Copy app source code
COPY --chown=node:node . .

# Expose API port
EXPOSE 3000

# Start command
CMD ["npm", "start"]

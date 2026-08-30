# Stage 1: Install dependencies
FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json .
RUN npm install --omit=dev --no-audit --no-fund

# Stage 2: Production image
FROM node:20-alpine
WORKDIR /app

# Add non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy only production dependencies and app code
COPY --from=deps /app/node_modules ./node_modules
COPY package.json .
COPY index.js .

# Switch to non-root user
USER appuser

EXPOSE 3000

# Set Node.js memory limit for small VMs (128MB max heap)
ENV NODE_OPTIONS="--max-old-space-size=128"

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost:3000/ || exit 1

CMD ["node", "index.js"]

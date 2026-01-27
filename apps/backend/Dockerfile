FROM momentum-base AS builder

ARG NODE_ENV=production
ARG BUILD_FLAG=--configuration=production

# Build the application
RUN npx nx build backend ${BUILD_FLAG}

FROM node:lts-alpine3.23
WORKDIR /app

# Copy only the built output and necessary runtime files
COPY --from=builder /app/dist/apps/backend ./dist/apps/backend
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

ENV NODE_ENV=${NODE_ENV}

CMD ["node", "./dist/apps/backend/main.js"]

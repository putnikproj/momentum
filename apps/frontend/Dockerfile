FROM momentum-base AS builder

ARG NODE_ENV=production
ARG BUILD_FLAG=--configuration=production

# Build the application
RUN npx nx build frontend ${BUILD_FLAG}

FROM nginx:1.29.4

COPY --from=builder /app/dist/apps/frontend/browser /usr/share/nginx/html
COPY --from=builder /app/apps/frontend/nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

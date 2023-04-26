FROM node:9 AS builder
WORKDIR /app

COPY . .

RUN \
  if [ -f yarn.lock ]; then yarn && yarn build:prod; \
  elif [ -f package-lock.json ]; then npm ci && npm run build:prod; \
  elif [ -f pnpm-lock.yaml ]; then yarn global add pnpm && pnpm i && pnpm run build:prod; \
  else echo "Lockfile not found." && exit 1; \
  fi

FROM nginx:alpine AS prod
WORKDIR /usr/share/nginx/html
COPY --from=builder /app/dist .
EXPOSE 80
ENTRYPOINT ["nginx", "-g", "daemon off;"]

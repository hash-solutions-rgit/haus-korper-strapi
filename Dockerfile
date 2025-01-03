FROM node:20-alpine as base


# Define build-time variables
ARG APP_KEYS
ARG API_TOKEN_SALT
ARG ADMIN_JWT_SECRET
ARG TRANSFER_TOKEN_SALT
ARG JWT_SECRET

 # Database
ARG DATABASE_CLIENT
ARG DATABASE_URL
ARG DATABASE_PORT
ARG DATABASE_NAME
ARG DATABASE_USERNAME
ARG DATABASE_PASSWORD
ARG DATABASE_SSL
 
 # SUPABASE
ARG SUPABASE_API_URL
ARG SUPABASE_URL
ARG SUPABASE_API_KEY
ARG SUPABASE_BUCKET

ARG SMTP_HOST
ARG SMTP_PORT
# Install dependencies only when needed
FROM base as deps
RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn --frozen-lockfile

# Build the source code
FROM base as builder
WORKDIR /app
COPY . .
COPY --from=deps /app/node_modules ./node_modules
RUN yarn build

# Remove devDependencies, keep only used dependencies
FROM base as production
RUN yarn install --production --ignore-optional --prefer-offline --pure-lockfile

# Switch to a non-root user
RUN addgroup -S strapi && adduser -S strapi -G strapi
USER strapi
WORKDIR /home/strapi

# Copy built contents into the image
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules

EXPOSE 1337

CMD ["yarn", "start"]
FROM node:20-alpine as base


# Define build-time variables
ARG HOST
ARG PORT

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
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn --frozen-lockfile

# Build the source code
FROM base as builder
WORKDIR /app
COPY . .
COPY --from=deps /app/node_modules ./node_modules

ENV DATABASE_CLIENT=$DATABASE_CLIENT
ENV DATABASE_URL=$DATABASE_URL
ENV DATABASE_PORT=$DATABASE_PORT
ENV DATABASE_NAME=$DATABASE_NAME
ENV DATABASE_USERNAME=$DATABASE_USERNAME
ENV DATABASE_PASSWORD=$DATABASE_PASSWORD
ENV DATABASE_SSL=$DATABASE_SSL
ENV SUPABASE_API_URL=$SUPABASE_API_URL
ENV SUPABASE_URL=$SUPABASE_URL
ENV SUPABASE_API_KEY=$SUPABASE_API_KEY
ENV SUPABASE_BUCKET=$SUPABASE_BUCKET
ENV SMTP_HOST=$SMTP_HOST
ENV SMTP_PORT=$SMTP_PORT

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
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/yarn.lock ./yarn.lock


EXPOSE 1337

CMD ["yarn", "start"]
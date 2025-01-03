FROM node:20.11.1-alpine AS base

WORKDIR /app

FROM base as dependencies

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

FROM base as build

COPY . .
COPY --from=dependencies /app/node_modules ./node_modules
RUN yarn build

FROM base as production

ENV NODE_ENV production
ENV PORT 1337

COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/yarn.lock ./yarn.lock

EXPOSE 1337

CMD ["yarn", "start"]
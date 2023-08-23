FROM node:16-alpine as base

RUN apk --no-cache add ca-certificates && \
  update-ca-certificates

RUN apk add curl wget

RUN npm i -g pnpm

WORKDIR /opt/app

FROM base AS installed

RUN curl https://raw.githubusercontent.com/sub-store-org/Sub-Store/master/backend/pnpm-lock.yaml -o pnpm-lock.yaml

RUN --mount=type=cache,id=pnpm-store,target=/root/.local/share/pnpm/store/v3\
  pnpm fetch

RUN curl https://raw.githubusercontent.com/sub-store-org/Sub-Store/master/backend/package.json -o package.json

RUN --mount=type=cache,id=pnpm-store,target=/root/.local/share/pnpm/store/v3\
  pnpm install -r --frozen-lockfile --offline --unsafe-perm

RUN curl -s https://api.github.com/repos/sub-store-org/Sub-Store/releases/latest \
  | grep "/sub-store.min.js" \
  | cut -d : -f 2,3 \
  | tr -d \" \
  | wget -qi -

FROM installed AS run

CMD node sub-store.min.js

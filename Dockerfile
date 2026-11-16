FROM node:14.21.3-buster-slim AS node
RUN rm -f /usr/local/bin/yarn /usr/local/bin/yarnpkg \
    && npm install --global yarn@1.22.22

FROM ruby:3.0.0
WORKDIR /app

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/bin/npm /usr/local/bin/npm
COPY --from=node /usr/local/bin/npx /usr/local/bin/npx
COPY --from=node /usr/local/lib/node_modules/yarn /usr/local/lib/node_modules/yarn
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules

RUN ln -sf ../lib/node_modules/yarn/bin/yarn.js /usr/local/bin/yarn \
    && ln -sf ../lib/node_modules/yarn/bin/yarn.js /usr/local/bin/yarnpkg
RUN gem install bundler -v 2.2.12

ENV BUNDLE_PATH=/bundle
EXPOSE 3000

CMD ["bundle", "_2.2.12_", "exec", "rails", "server", "-b", "0.0.0.0"]
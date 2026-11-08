# Shop — Setup and Run with Docker

This project is an e-commerce application built with Ruby on Rails. Docker provides the older Ruby and Node.js versions it requires, so they do not need to be installed locally.

## Prerequisites

- Git
- Docker Desktop with Docker Compose v2
- Docker Engine running

## Get the project

Clone the repository and check out the `dev` branch:

```bash
git clone -b dev <repository-url> shop
cd shop
```

If you have already cloned the repository:

```bash
git switch dev
git pull
```

## First-time setup

Run the following commands from the project root directory.

### 1. Build the Docker image

```bash
docker compose build
```

The image includes Ruby 3.0.0, Bundler 2.2.12, Node.js 14, and Yarn 1.22.22.

### 2. Install the Ruby gems

```bash
docker compose run --rm web bundle _2.2.12_ install
```

### 3. Install the JavaScript packages

```bash
docker compose run --rm web yarn install --frozen-lockfile
```

### 4. Create or update the database

```bash
docker compose run --rm web bundle _2.2.12_ exec rails db:migrate
```

### 5. Load the sample data

```bash
docker compose run --rm web bundle _2.2.12_ exec rails db:seed
```

The seed creates one sample user and four products. If you see `Email has already been taken`, the database already contains the sample user and likely the sample data. Check the database before running the seed again.

### 6. Start the server

```bash
docker compose up
```

Open [http://localhost:3000](http://localhost:3000). Keep the terminal open while using the app. Press `Ctrl+C` to stop the server.

## Subsequent runs

After the initial setup, start the app with:

```bash
docker compose up
```

## Notes

- The SQLite database is stored at `db/development.sqlite3` in the project directory.
- Ruby gems and JavaScript packages are stored in Docker volumes, so they do not need to be reinstalled each time.
- Do not run `bundle update` as part of the normal setup. `Gemfile.lock` pins the gem versions. The locked `mimemagic` version was updated to `0.3.10` because the original version, `0.3.6`, was unavailable from RubyGems.
- During the first run, Webpacker reported an empty `configuration.entry`, although the homepage returned HTTP 200 and displayed the products. If this error keeps appearing or JavaScript features do not work, investigate the Webpacker configuration.

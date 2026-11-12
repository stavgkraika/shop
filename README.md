## Tests

The project uses Rails' built-in Minitest framework. The test suite includes
model, integration, and system tests.

With Docker and Docker Compose available, run all tests with:

```bash
docker compose run --rm --use-aliases test
```

Compose starts a Selenium container for the system tests. The `--use-aliases`
option allows the browser to reach the test application through the Docker
network.

The test database is separate from the development database.

For manual checks, see [docs/audit.md](docs/audit.md). Mark each item after
testing it and record any failures in the notes.
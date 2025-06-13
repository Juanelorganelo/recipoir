db_url := "postgresql://postgres:12345@localhost:5433/items?sslmode=disable"
db_name := "items"
db_user := "postgres"
db_password := "12345"
db_host := "localhost"
db_port := "5433"
atlas_dir := "src/main/resources/atlas"
atlas_schema_file := atlas_dir + "/schema.pg.hcl"
atlas_migrations_dir := atlas_dir + "/migrations"

[doc("Show available tasks")]
@default:
    just --list

[doc("Start PostgreSQL and Redpanda with Docker Compose")]
@services-up:
    #!/usr/bin/env bash
    is_ready() {
        docker compose exec postgres pg_isready -U {{ db_user }} -d {{ db_name }}
    }
    
    docker compose up -d
    while ! is_ready; do
        sleep 1
    done
    echo "PostgreSQL is ready"

[doc("Stop PostgreSQL and Redpanda with Docker Compose")]
@services-down:
    docker compose down

[doc("Removes the docker containers and volumes")]
@services-clean:
    docker compose down -v
    docker volume prune -f

[doc("Install Atlas CLI")]
@atlas-install:
    #!/usr/bin/env bash
    if ! command -v atlas &> /dev/null; then
        echo "Installing Atlas CLI..."
        curl -sSf https://atlasgo.sh | sh
    else
        echo "Atlas CLI already installed"
    fi

[doc("Creates migrations by diffing the database schema and our HCL definition")]
@atlas-diff:
    atlas migrate diff create_users \
        --dir "file://{{ atlas_migrations_dir }}" \
        --to "file://{{ atlas_schema_file }}" \
        --dev-url "docker://postgres/15/dev?search_path=public"

[doc("Applies migrations")]
@atlas-apply:
    atlas migrate apply \
        --dir "file://{{ atlas_schema_file }}" \
        --url "docker://postgres/15/dev?search_path=public"

[doc("Run the server")]
@server-run:
    sbt run

[doc("Run server tests")]
@server-test:
    sbt test

[doc("Clean server build artifacts")]
@server-clean:
    sbt clean

[doc("Set up development environment")]
@dev-setup:
    #!/usr/bin/env bash
    just atlas-install
    just compose-up
    just atlas-apply
    echo "Development environment ready!"

[doc("Reset development environment")]
@dev-reset:
    #!/usr/bin/env bash
    set -ex pipefail

    just compose-clean
    just compose-up
    just atlas-apply
    echo "Development environment reset!"

[doc("Check code formatting")]
@format-check:
    sbt scalafmtCheckAll

[doc("Update dependencies")]
@deps-update:
    sbt dependencyUpdate

[doc("Show container logs")]
@logs:
    docker compose logs -f

[doc("Clean all build artifacts and containers")]
@clean-all:
    just server-clean
    just compose-clean
    echo "All cleaned up!"

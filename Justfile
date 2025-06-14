db_url := "postgresql://postgres:12345@localhost:5433/items?sslmode=disable"
db_name := "items"
db_user := "postgres"
db_password := "12345"
db_host := "localhost"
db_port := "5433"
atlas_dir := "src/main/resources/atlas"
atlas_schema_file := atlas_dir + "/schema.pg.hcl"
atlas_migrations_dir := atlas_dir + "/migrations"

# The default task i.e. gets run with `just`
@_default: help

# Wait for required app services to be ready
@_wait-services:
    #!/usr/bin/env bash
    set -euox pipefail
    # Add the redpanda stuff when we need to.    
    while ! docker compose exec postgres pg_isready -U {{ db_user }} -d {{ db_name }}; do
        sleep 1
    done

[doc("Show available tasks")]
@help:
    just --list

[doc("Start our PostgreSQL server")]
@db-up:
    #!/usr/bin/env bash
    set -euox pipefail
    docker compose up -d
    while ! docker compose \
        exec postgres pg_isready \
        -U {{ db_user }} -d {{ db_name }}
    do
        sleep 1
    done
    echo "PostgreSQL is ready"

[doc("Stop our PostgreSQL server")]
@db-down:
    docker compose down

[doc("Removes the docker containers and volumes")]
@db-nuke force:
    #!/usr/bin/env bash
    set -euox pipefail

    # just db-nuke force will trigger this
    if [ "{{ force }}" == "force" ]; then
        docker compose down -v
    else
        echo "Are you sure? This will delete all data in your local database"
        select strictreply in "Yes" "No"; do
            relaxedreply=${strictreply:-$REPLY}
            case $relaxedreply in
                Yes | yes | y ) docker compose down -v ; break ;;
                No  | no  | n ) exit ;;
            esac
        done
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

[doc("Set up development environment and run the application")]
@dev:
    #!/usr/bin/env bash
    just compose-up atlas-apply
    echo "Development environment ready!"
    sbt

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

@_logs service="":
    docker compose logs -f {{ service }}

[doc("Show logs from all containers")]
@logs-all: _logs

[doc("Show database logs")]
@logs-db: (_logs "postgres")

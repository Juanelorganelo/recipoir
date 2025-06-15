set dotenv-required

db_url := "postgresql://postgres:12345@localhost:5433/items?sslmode=disable"
db_name := "items"
db_user := "postgres"
db_password := "12345"
db_host := "localhost"
db_port := "5433"
atlas_dir := "src/main/resources"
atlas_schema_file := atlas_dir + "/schema.pg.hcl"

# The default task i.e. gets run with `just`
_default: help

[doc("Show available tasks")]
help:
    just --list

[doc("Start our PostgreSQL server")]
db-up:
    #!/usr/bin/env bash
    set -euo pipefail
    docker compose run --remove-orphans -d postgres
    while ! docker compose \
        exec postgres pg_isready \
        -U {{ db_user }} -d {{ db_name }}
    do
        sleep 1
    done
    echo "PostgreSQL is ready"

[doc("Stop our PostgreSQL server")]
db-down:
    docker compose kill --remove-orphans postgres

[doc("Removes the docker containers and volumes")]
db-nuke force="":
    #!/usr/bin/env bash
    set -euo pipefail

    # just db-nuke force will trigger this
    if [ "{{ force }}" == "force" ]; then
        docker compose down -v
    elif [[ -z "{{ force }}" ]]; then
        echo "Are you sure? This will delete all data in your local database"
        select strictreply in "Yes" "No"; do
            relaxedreply=${strictreply:-$REPLY}
            case $relaxedreply in
                Yes | yes | y ) docker compose down -v ; break ;;
                No  | no  | n ) exit ;;
                * ) echo "Invalid reply $relaxedreply" ;;
            esac
        done
    else
        echo "Invalid argument provided to db-nuke. Accepted values are 'force' or the empty string"
    fi

[doc("Applies migrations")]
dev-atlas-apply +args="":
    atlas schema apply \
        --to "file://{{ atlas_schema_file }}" \
        --url "$ATLAS_URL" {{ args }}

[doc("Set up development environment and run the application")]
dev: db-up dev-atlas-apply
    sbt run --watch

[doc("Check code formatting")]
format-check:
    sbt scalafmtCheckAll

[doc("Update dependencies")]
deps-update:
    sbt dependencyUpdate

_logs service="":
    docker compose logs -f {{ service }}

[doc("Show logs from all containers")]
logs-all: _logs

[doc("Show database logs")]
logs-db: (_logs "postgres")

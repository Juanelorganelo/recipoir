set dotenv-required

atlas_dir := "src/main/resources"
atlas_schema_file := atlas_dir + "/schema.pg.hcl"

# The default task i.e. gets run with `just`
_default: help

[doc("Show available tasks")]
help:
    just --list

alias dev := up
[doc("Set up development environment and run the application")]
up: services-up migrate-apply
    sbt ~run

alias tear := down
[doc("Tear down development environment and server")]
down: services-down

[doc("Start development external services")]
services-up:
    #!/usr/bin/env bash
    set -euo pipefail
    docker compose up -d
    while ! docker compose exec postgres pg_isready -U $DB_USER -d $DB_NAME; do
        sleep 1
    done
    echo "PostgreSQL is ready"

[doc("Stop our PostgreSQL server")]
services-down:
    docker compose down

[doc("Removes the docker containers and volumes")]
services-nuke force="":
    #!/usr/bin/env bash
    set -euo pipefail

    nuke() {
        docker compose down -v
    }

    # just services-nuke force will trigger this
    if [ "{{ force }}" == "force" ]; then
        nuke
    elif [[ -z "{{ force }}" ]]; then
        echo "Are you sure? This will delete all data in your local database"
        select strictreply in "Yes" "No"; do
            relaxedreply=${strictreply:-$REPLY}
            case $relaxedreply in
                Yes | yes | y ) nuke ; break ;;
                No  | no  | n ) exit ;;
                * ) echo "Invalid reply $relaxedreply" ;;
            esac
        done
    else
        echo "Invalid argument provided to services-nuke. Accepted values are 'force' or the empty string. Got '{{ force }}'."
    fi

[doc("Creates SQL migrations by diffing the Atlas schema and the DB schema")]
migrate-diff +args="":
    atlas schema diff \
        --to "file://{{ atlas_schema_file }}" \
        --url "$DB_URL" {{ args }}

[doc("Applies database migrations")]
migrate-apply +args="":
    atlas schema apply \
        --to "file://{{ atlas_schema_file }}" \
        --url "$DB_URL" {{ args }}

[doc("Format the code with scalafmt")]
format:
    sbt scalafmtAll

[doc("Check code formatting")]
format-check:
    sbt scalafmtCheckAll

_logs service="":
    docker compose logs -f {{ service }}

[doc("Show logs from all containers")]
logs-all: _logs

[doc("Show database logs")]
logs-db: (_logs "postgres")

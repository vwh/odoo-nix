set shell := ["/usr/bin/env", "bash", "-c"]
set quiet

# Variables
ODOO_BIN := "./odoo/odoo-bin"
ADDONS_PATH := "odoo/addons,custom_addons"
DB_NAME := "odoo-dev"
DB_HOST := "127.0.0.1"
DB_PORT := "5433"

# First-time setup: drop database, recreate, and initialize with base module
init:
	@echo "Initializing Odoo database for first time..."
	@echo "Dropping existing database if it exists..."
	-dropdb -h {{DB_HOST}} -p {{DB_PORT}} -U "$USER" "{{DB_NAME}}" 2>/dev/null || true
	@echo "Creating fresh database..."
	createdb -h {{DB_HOST}} -p {{DB_PORT}} -U "$USER" "{{DB_NAME}}"
	@echo "Initializing Odoo with base module..."
	"{{ODOO_BIN}}" \
	  --addons-path="{{ADDONS_PATH}}" \
	  --db_host={{DB_HOST}} \
	  --db_port={{DB_PORT}} \
	  --db_user="$USER" \
	  -d "{{DB_NAME}}" \
	  -i base \
	  --stop-after-init \
	  --without-demo=all
	@echo "Database initialized successfully!"

reset:
	@echo "Resetting Odoo database..."
	-dropdb -h {{DB_HOST}} -p {{DB_PORT}} -U "$USER" "{{DB_NAME}}" 2>/dev/null || true
	createdb -h {{DB_HOST}} -p {{DB_PORT}} -U "$USER" "{{DB_NAME}}"
	"{{ODOO_BIN}}" -d "{{DB_NAME}}" -i base --stop-after-init --without-demo=all

run:
    @echo "Starting Odoo server with extra args: $@"
    "{{ODOO_BIN}}" \
      -d "{{DB_NAME}}" \
      --dev=all \
      "$@"

update modules:
	@echo "Updating Odoo modules: {{modules}}..."
	"{{ODOO_BIN}}" -d "{{DB_NAME}}" -u "{{modules}}" --stop-after-init
	@echo "Modules updated. Restart Odoo server to apply changes."

install modules:
	@echo "Installing Odoo modules: {{modules}}..."
	"{{ODOO_BIN}}" -d "{{DB_NAME}}" -i "{{modules}}" --stop-after-init
	@echo "Modules installed. Restart Odoo server to apply changes."

shell:
    @echo "Launching Odoo shell..."
    "{{ODOO_BIN}}" shell -d "{{DB_NAME}}"

test modules:
	@echo "Running tests for Odoo modules: {{modules}}..."
	"{{ODOO_BIN}}" -d "{{DB_NAME}}" -u "{{modules}}" --test-enable --stop-after-init
	@echo "Tests completed."

scaffold module_name:
	@echo "Scaffolding new Odoo module: {{module_name}} in custom_addons/..."
	mkdir -p custom_addons
	"{{ODOO_BIN}}" scaffold "{{module_name}}" "custom_addons"
	@echo "Module '{{module_name}}' created. Then run `just install-modules {{module_name}}` to install it."

status:
	@echo "Database status:"
	@echo "Database: {{DB_NAME}}"
	@if psql -h {{DB_HOST}} -p {{DB_PORT}} -U "$USER" -lqt \
		| cut -d \| -f 1 \
		| grep -qw "{{DB_NAME}}"; then \
	  echo "✓ Database exists"; \
	  echo "Tables:"; \
	  psql -h {{DB_HOST}} -p {{DB_PORT}} -U "$USER" -d "{{DB_NAME}}" -c "\dt" \
	    | head -10; \
	else \
	  echo "✗ Database does not exist"; \
	fi

db-kill:
	@echo "Killing all database connections..."
	-psql -h {{DB_HOST}} -p {{DB_PORT}} \
	  -c "SELECT pg_terminate_backend(pid) \
	      FROM pg_stat_activity \
	      WHERE datname = '{{DB_NAME}}' \
	        AND pid <> pg_backend_pid();" \
	  2>/dev/null || true

db-restart:
	@echo "Restarting PostgreSQL..."
	pg_ctl -D ./.pgdata restart -m fast
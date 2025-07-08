set shell := ["/usr/bin/env", "bash", "-c"]
set quiet

# Variables
ODOO_BIN := "./odoo/odoo-bin"
ADDONS_PATH := "odoo/addons,custom_addons"
DB_NAME := "odoo-dev"

# Recipes
@run:
	@echo "Starting Odoo server..."
	"{{ODOO_BIN}}" -d "{{DB_NAME}}" --addons-path="{{ADDONS_PATH}}" --dev=all "$@"

@update modules:
	@echo "Updating Odoo modules: {{modules}}..."
	"{{ODOO_BIN}}" -d "{{DB_NAME}}" -u "{{modules}}" --addons-path="{{ADDONS_PATH}}" --stop-after-init
	@echo "Modules updated. Restart Odoo server to apply changes."

@install modules:
	@echo "Installing Odoo modules: {{modules}}..."
	"{{ODOO_BIN}}" -d "{{DB_NAME}}" -i "{{modules}}" --addons-path="{{ADDONS_PATH}}" --stop-after-init
	@echo "Modules installed. Restart Odoo server to apply changes."

@shell:
	@echo "Launching Odoo shell..."
	"{{ODOO_BIN}}" shell -d "{{DB_NAME}}" --addons-path="{{ADDONS_PATH}}" "$@"

@test modules:
	@echo "Running tests for Odoo modules: {{modules}}..."
	"{{ODOO_BIN}}" -d "{{DB_NAME}}" -u "{{modules}}" --addons-path="{{ADDONS_PATH}}" --test-enable --stop-after-init
	@echo "Tests completed."

@scaffold module_name:
	@echo "Scaffolding new Odoo module: {{module_name}} in custom_addons/ ..."
	"{{ODOO_BIN}}" scaffold "{{module_name}}" "custom_addons"
	@echo "Module '{{module_name}}' created. You can now develop it and then run 'just install {{module_name}}' to install it."

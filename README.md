# Odoo Nix Support

This repository provides a Nix flake-based development environment for Odoo 18, ensuring a reproducible and consistent setup across different machines. It includes all necessary system dependencies, Python packages, and frontend compilation tools (like `sassc`, `less`, and `rtlcss`) to get Odoo running smoothly on NixOS.

## Installation

### 1. Clone the Odoo Source

It is assumed you have already cloned the Odoo 18 source code into the `odoo/` directory.

```
git clone -b 18 https://github.com/odoo/odoo.git
```

### 2. Set Up the Nix Environment

This project uses a Nix flake to provide a reproducible development environment. It includes:
- Python 3.12 and its packages (from `odoo-requirements.txt`)
- PostgreSQL 16 (managed by Nix)
- Frontend compilation tools: `nodejs`, `less`, `rtlcss`, `sassc`, and `libsass`.
- `just` command runner for simplified development workflows.

To activate the development environment, run:

```bash
nix develop
```

This will drop you into a shell with all the necessary system and Python dependencies, and ensure the frontend compilation tools are available.

### 3. Create the Database

Ensure your PostgreSQL user has create permissions, then create a new database for this project.

```bash
createdb odoo-dev
```

## Odoo Development Workflow

Here's a typical development flow when working with Odoo:

1.  **Environment Setup (One-time/Initial):**
    *   Clone the Odoo source.
    *   Enter your Nix development shell: `nix develop`.
    *   Create your Odoo database: `createdb odoo-dev` (if not already done).

2.  **Start the Development Server:**
    *   Use the `just run` command: `just run`.
    *   This starts Odoo, connecting to your `odoo-dev` database. For most changes, you'll keep this server running.

3.  **Make Code Changes:**
    *   **Python (`.py` files):** Modify models, business logic, controllers, etc. After saving, Odoo's server usually needs to be restarted for these changes to take effect.
    *   **XML (`.xml` files):** Modify views, menus, security rules, data records. If `--dev=all` is enabled (which it is in `just run`), many XML changes (especially views) will hot-reload without a server restart.
    *   **Static Assets (`.scss`, `.js`, `.css`, images):** Modify frontend styles or JavaScript. With `--dev=all`, these changes should also hot-reload in your browser.

4.  **Update/Install Modules (When Necessary):**
    *   If you've added new fields, changed Python model definitions significantly, or added new modules, you'll need to update the relevant module(s).
    *   **Update:** `just update <module_name>` (e.g., `just update my_module` or `just update all`). This will apply the structural changes to the database. After an update, you'll need to restart your `just run` server.
    *   **Install:** `just install <new_module_name>`. This is for adding entirely new modules to your database.

5.  **Testing:**
    *   Run tests for specific modules: `just test <module_name>` (e.g., `just test my_module` or `just test all`).

6.  **Debugging:**
    *   For Python code, you can use a debugger (like `pdb` or integrate with VS Code's debugger).
    *   For frontend issues, use your browser's developer tools.
    *   For database interaction, `just shell` provides an interactive Python shell connected to your Odoo environment.

## Running Commands with `just`

This project uses `just` to simplify common Odoo development commands. Make sure you are in the `nix develop` shell before running these commands.

### Core Development

- **Initialize the database (first time only):**
  ```bash
  just init
  ```
  This command prepares the database for the first time by creating it and installing the `base` module.

- **Start the Odoo server:**
  ```bash
  just run
  ```
  You can pass additional `odoo-bin` arguments directly:
  ```bash
  just run --xmlrpc-port=8070 --log-level=debug
  ```

- **Update Odoo modules:**
  ```bash
  just update base,web
  # or to update all modules:
  just update all
  ```

- **Install Odoo modules:**
  ```bash
  just install my_module
  ```

- **Launch Odoo shell:**
  ```bash
  just shell
  ```

- **Run tests for Odoo modules:**
  ```bash
  just test my_module
  # or to run tests for all modules:
  just test all
  ```

- **Scaffold a new Odoo module:**
  ```bash
  just scaffold my_new_module
  ```
  This will create the basic module structure in `custom_addons/my_new_module`.

### Database Management

- **Reset the database:**
  ```bash
  just reset
  ```
  This will completely wipe the database and re-initialize it. Use with caution.

- **Check database status:**
  ```bash
  just status
  ```
  This shows if the database exists and lists some of its tables.

- **Restart the PostgreSQL server:**
  ```bash
  just db-restart
  ```
  This restarts the PostgreSQL instance managed by the Nix shell.

- **Kill database connections:**
  ```bash
  just db-kill
  ```
  This forcibly terminates all active connections to the Odoo database, which can be useful if the server is stuck.

### Access the Application

Once started, access your Odoo instance at:
- **URL**: `http://localhost:8069`
- **Database**: `odoo-dev`
- **Default Admin**: `admin` / `admin`

## Development Setup

### Cleaning Odoo Data

To perform a clean start (e.g., after major changes or if assets are corrupted), you can:
1.  Stop Odoo.
2.  Drop the PostgreSQL database: `dropdb odoo-dev` (or use `psql` if `dropdb` is not in PATH).

### VS Code Configuration

The project includes VS Code settings for optimal development experience:

```json
{
    "python.analysis.extraPaths": [
        "./odoo",
        "./custom_addons"
    ]
}
```
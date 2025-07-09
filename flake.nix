{
  description = "Odoo 18 development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        python = pkgs.python312;
        pyPkgs = pkgs.python312Packages;
        nodejs = pkgs.nodejs_22;
        nodePkgs = pkgs.nodePackages;
      in
      {
        devShells.default = pkgs.mkShell {
          name = "odoo-dev";
          venvDir = "./.venv";

          buildInputs = with pkgs; [
            # Python environment
            python
            pyPkgs.venvShellHook
            pyPkgs.psycopg2 # Python PostgreSQL connector
            pyPkgs.inotify # Odoo filesystem watcher

            # Node.js environment
            nodejs
            nodePkgs.less #  Odoo frontend asset compilation
            nodePkgs.rtlcss # Odoo frontend asset compilation

            # Database
            postgresql_16

            # Build tools
            sassc # Odoo SCSS compilation
            libsass
            
            # Development tools
            just # Command runner
            
            # System libraries
            libxml2
            libxslt
            libjpeg
            libpng
            zlib 
            freetype
            wkhtmltopdf
            
            # Fonts
            dejavu_fonts
            freefont_ttf
            noto-fonts
            inconsolata
            font-awesome
            roboto
            ghostscript
          ];

          postVenvCreation = ''
            unset SOURCE_DATE_EPOCH
            pip install -r odoo-requirements.txt
          '';

          postShellHook = ''
            unset SOURCE_DATE_EPOCH
            
            # PostgreSQL setup
            export PGDATA=$PWD/.pgdata
            export PGHOST=127.0.0.1
            export PGPORT=5433

            # initdb once
            if [ ! -f "$PGDATA/PG_VERSION" ]; then
              echo "› initdb → $PGDATA"
              mkdir -p "$PGDATA"
              initdb --encoding=UTF8 \
                    --username="$USER" \
                    --auth-local=trust \
                    --auth-host=trust \
                    "$PGDATA"
            fi

            # start if not already running
            if ! pg_ctl -D "$PGDATA" status >/dev/null 2>&1; then
              echo "› pg_ctl start → $PGHOST:$PGPORT (TCP only)"
              pg_ctl -D "$PGDATA" \
                    -o "-F -p $PGPORT -h $PGHOST -k $PGDATA" \
                    -l "$PGDATA/server.log" \
                    start || {
                echo "PostgreSQL failed to start. Check .pgdata/server.log"
                echo "Continuing without PostgreSQL..."
              }
            fi

            export PGDATABASE=odoo-dev

            echo "Python venv: $(which python)"
            echo "PostgreSQL: $PGHOST:$PGPORT"
          '';
        };
      }
    );
}
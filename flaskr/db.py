import click
import pymysql
import pymysql.cursors
from flask import current_app
from flask import g


def get_db():
    """Connect to the application's configured database."""
    if "db" not in g:
        g.db = pymysql.connect(
            host=current_app.config.get("MYSQL_HOST", "localhost"),
            user=current_app.config.get("MYSQL_USER", "root"),
            password=current_app.config.get("MYSQL_PASSWORD", ""),
            database=current_app.config.get("MYSQL_DB", "flaskapp"),
            cursorclass=pymysql.cursors.DictCursor,
            autocommit=False
        )

    return g.db


def close_db(e=None):
    """If this request connected to the database, close the connection."""
    db = g.pop("db", None)

    if db is not None:
        db.close()


def init_db():
    """Clear existing data and create new tables."""
    db = get_db()

    with current_app.open_resource("schema.sql") as f:
        sql = f.read().decode("utf8")
        with db.cursor() as cursor:
            for statement in sql.split(';'):
                if statement.strip():
                    cursor.execute(statement)
        db.commit()


@click.command("init-db")
def init_db_command():
    """Clear existing data and create new tables."""
    init_db()
    click.echo("Initialized the database.")


def init_app(app):
    """Register database functions with the Flask app."""
    app.teardown_appcontext(close_db)
    app.cli.add_command(init_db_command)

IntegrityError = pymysql.err.IntegrityError

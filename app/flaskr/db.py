import os
import click
import psycopg2
import psycopg2.extras
from flask import current_app
from flask import g


def get_db():
    """Connect to the application's configured database."""
    if "db" not in g:
        g.db = psycopg2.connect(
            host=os.environ.get("DB_HOST", "localhost"),
            user=os.environ.get("DB_USER", "postgres"),
            password=os.environ.get("DB_PASSWORD", "postgres"),
            dbname=os.environ.get("DB_NAME", "flaskapp"),
            port=os.environ.get("DB_PORT", "5432"),
            cursor_factory=psycopg2.extras.DictCursor
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

IntegrityError = psycopg2.IntegrityError

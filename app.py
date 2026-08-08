import hashlib
import os
import secrets
from contextlib import contextmanager
from datetime import date, datetime, timedelta, timezone

import psycopg
from flask import Flask, abort, redirect, render_template, request, url_for
from psycopg.rows import dict_row


app = Flask(__name__)

CUSTOM_ITEM_CATEGORY = "Things we might have missed"
BABY_SHOWER_DATE = date(2026, 10, 31)
SOUTH_AFRICA_TIME = timezone(timedelta(hours=2))

ITEM_GROUPS = (
    ("Sleep & nursery", {"Sleep", "Nursery"}),
    ("Changing & travel", {"Changing and travel", "Getting around"}),
    ("Care", {"Bath and care", "Health and care"}),
    ("Clothing", {"Clothing"}),
    ("Parents’ irritation", {"Parents irritation"}),
    ("Feeding", {"Feeding"}),
    ("Everyday essentials", {"Everyday essentials"}),
    (CUSTOM_ITEM_CATEGORY, {CUSTOM_ITEM_CATEGORY}),
)


@contextmanager
def database():
    connection = psycopg.connect(
        os.environ["DATABASE_URL"],
        row_factory=dict_row,
        connect_timeout=5,
    )
    try:
        yield connection
        connection.commit()
    except Exception:
        connection.rollback()
        raise
    finally:
        connection.close()


def token_hash(token):
    return hashlib.sha256(token.encode("utf-8")).hexdigest()


def baby_shower_status(today=None):
    if today is None:
        today = datetime.now(SOUTH_AFRICA_TIME).date()

    days_remaining = (BABY_SHOWER_DATE - today).days
    return {
        "days_remaining": max(days_remaining, 0),
        "is_today": days_remaining == 0,
        "has_passed": days_remaining < 0,
    }


def list_items():
    with database() as connection:
        return connection.execute(
            """
            select
                id,
                title,
                description,
                category,
                purchase_url,
                claim_mode,
                claim_count,
                is_available,
                max_claims
            from registry.public_items
            order by display_order, title
            """
        ).fetchall()


def create_claim(item_id, undo_token_hash):
    with database() as connection:
        row = connection.execute(
            "select * from registry.create_claim(%s, %s)",
            (item_id, undo_token_hash),
        ).fetchone()
    return row["result"]


def release_claim(undo_token_hash):
    with database() as connection:
        row = connection.execute(
            "select registry.release_claim(%s) as released",
            (undo_token_hash,),
        ).fetchone()
    return row["released"]


def release_one_claim_for_item(item_id):
    with database() as connection:
        row = connection.execute(
            "select registry.release_one_claim_for_item(%s) as released",
            (item_id,),
        ).fetchone()
    return row["released"]


def add_custom_item(title):
    with database() as connection:
        row = connection.execute(
            "select registry.add_custom_item(%s) as item_id",
            (title,),
        ).fetchone()
    return row["item_id"]


def remove_custom_item(item_id):
    with database() as connection:
        row = connection.execute(
            "select registry.remove_custom_item(%s) as removed",
            (item_id,),
        ).fetchone()
    return row["removed"]


def group_items(items):
    grouped = []
    assigned_categories = set()

    for title, categories in ITEM_GROUPS:
        group_items_for_title = [
            item for item in items if item["category"] in categories
        ]
        if group_items_for_title or title == CUSTOM_ITEM_CATEGORY:
            grouped.append(
                {
                    "title": title,
                    "items": group_items_for_title,
                    "allows_custom_items": title == CUSTOM_ITEM_CATEGORY,
                }
            )
            assigned_categories.update(categories)

    remaining_items = [
        item for item in items if item["category"] not in assigned_categories
    ]
    if remaining_items:
        grouped.append({"title": "Other", "items": remaining_items})

    return grouped


@app.after_request
def security_headers(response):
    response.headers["Content-Security-Policy"] = (
        "default-src 'self'; "
        "script-src 'self'; "
        "style-src 'self'; "
        "img-src 'self' data:; "
        "base-uri 'none'; "
        "form-action 'self'; "
        "frame-ancestors 'none'"
    )
    response.headers["Referrer-Policy"] = "no-referrer"
    response.headers["X-Content-Type-Options"] = "nosniff"
    return response


@app.get("/")
def index():
    notice = request.args.get("notice")
    return render_template(
        "index.html",
        item_groups=group_items(list_items()),
        notice=notice,
        custom_item_category=CUSTOM_ITEM_CATEGORY,
        baby_shower=baby_shower_status(),
    )


@app.post("/items/<uuid:item_id>/claim")
def claim_item(item_id):
    token = secrets.token_urlsafe(32)
    result = create_claim(item_id, token_hash(token))

    if result == "not_found":
        abort(404)
    if result == "already_claimed":
        return redirect(
            url_for("index", notice="already_claimed") + f"#item-{item_id}",
            code=303,
        )
    if result == "claim_limit_reached":
        return redirect(
            url_for("index", notice="claim_limit_reached") + f"#item-{item_id}",
            code=303,
        )

    item_title = request.form.get("item_title", "Registry item")[:120]
    return (
        render_template(
            "claim_confirmation.html",
            item_id=item_id,
            item_title=item_title,
            undo_token=token,
        ),
        201,
    )


@app.post("/claims/undo")
def undo_claim():
    token = request.form.get("undo_token", "").strip()
    if not token or len(token) > 200:
        return render_template(
            "undo_result.html",
            released=False,
            undo_token="",
            invalid=True,
        ), 400

    released = release_claim(token_hash(token))
    return render_template(
        "undo_result.html",
        released=released,
        undo_token=token if released else "",
        invalid=False,
    )


@app.post("/items/<uuid:item_id>/unclaim")
def unclaim_item(item_id):
    released = release_one_claim_for_item(item_id)
    notice = "unclaimed" if released else "nothing_to_unclaim"
    return redirect(url_for("index", notice=notice) + f"#item-{item_id}", code=303)


@app.post("/items/add")
def add_item():
    title = " ".join(request.form.get("title", "").split())
    if not 2 <= len(title) <= 120:
        return redirect(
            url_for("index", notice="invalid_custom_item") + "#missed-items",
            code=303,
        )

    item_id = add_custom_item(title)
    if item_id is None:
        return redirect(
            url_for("index", notice="invalid_custom_item") + "#missed-items",
            code=303,
        )

    return redirect(
        url_for("index", notice="custom_item_added") + f"#item-{item_id}",
        code=303,
    )


@app.post("/items/<uuid:item_id>/remove")
def remove_item(item_id):
    removed = remove_custom_item(item_id)
    notice = "custom_item_removed" if removed else "item_not_removable"
    return redirect(url_for("index", notice=notice) + "#missed-items", code=303)


@app.get("/health")
def health():
    try:
        with database() as connection:
            connection.execute("select 1")
    except psycopg.Error:
        return {"status": "unhealthy"}, 503
    return {"status": "ok"}


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080, debug=True)

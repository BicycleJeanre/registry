import hashlib
import os
import secrets
from contextlib import contextmanager
from datetime import date, datetime, timedelta, timezone

import psycopg
from flask import Flask, abort, redirect, render_template, request, url_for
from psycopg.rows import dict_row


APP_DIR = os.path.dirname(os.path.abspath(__file__))
app = Flask(
    __name__,
    template_folder=os.path.join(APP_DIR, "templates"),
    static_folder=os.path.join(APP_DIR, "static"),
)

CUSTOM_ITEM_CATEGORY = "Things we might have missed"
BABY_SHOWER_DATE = date(2026, 10, 31)
SOUTH_AFRICA_TIME = timezone(timedelta(hours=2))

ITEM_GROUPS = (
    ("Feeding", {"Feeding"}),
    (
        "Care & bath",
        {"Care and bath", "Bath and care", "Health and care", "Everyday essentials"},
    ),
    ("Clothing", {"Clothing"}),
    ("Sleep", {"Sleep", "Nursery"}),
    ("Out & about", {"Out and about", "Changing and travel", "Getting around"}),
    ("Play & other", {"Play and other", "Parents irritation"}),
    ("For Mom", {"For Mom"}),
    (CUSTOM_ITEM_CATEGORY, {CUSTOM_ITEM_CATEGORY}),
)

ITEM_GROUP_NOTES = {
    "Care & bath": (
        "Nappies are welcome in sizes 2, 3 and 4 only — no newborn nappies, please."
    ),
    "For Mom": "A few thoughtful comforts for Mom.",
}

ITEM_GROUP_TITLES_AF = {
    "Feeding": "Voeding",
    "Care & bath": "Versorging en badtyd",
    "Clothing": "Klere",
    "Sleep": "Slaap",
    "Out & about": "Op pad",
    "Play & other": "Speel en ander",
    "For Mom": "Vir Mamma",
    CUSTOM_ITEM_CATEGORY: "Dinge wat ons dalk gemis het",
    "Other": "Ander",
}

ITEM_GROUP_NOTES_AF = {
    "Care & bath": (
        "Doeke is slegs welkom in groottes 2, 3 en 4 — geen pasgebore "
        "doeke nie, asseblief."
    ),
    "For Mom": "’n Paar bedagsame bederfies vir Mamma.",
}

ITEM_TITLES_AF = {
    "00000000-0000-4000-8000-000000000055": "Borsvoedingsdoek",
    "00000000-0000-4000-8000-000000000056": "Melkopvangers",
    "00000000-0000-4000-8000-000000000057": "Borsmelk-vriessakkies",
    "00000000-0000-4000-8000-000000000083": "Voedingskussing",
    "00000000-0000-4000-8000-000000000020": "Borskompressies",
    "00000000-0000-4000-8000-000000000024": "Bababottels",
    "00000000-0000-4000-8000-000000000025": "Ekstra bottelspene",
    "00000000-0000-4000-8000-000000000052": (
        "Ekstra stadigevloei-bottelspene vir pasgeborenes"
    ),
    "00000000-0000-4000-8000-000000000026": "Bottelborsel",
    "00000000-0000-4000-8000-000000000054": "Mikrogolf-bottelsteriliseerder",
    "00000000-0000-4000-8000-000000000027": "Fopspene",
    "00000000-0000-4000-8000-000000000028": "Slabbetjies",
    "55555555-5555-4555-8555-555555555555": "Oprispdoeke of moeseliendoeke",
    "00000000-0000-4000-8000-000000000015": "Sagte handdoeke met kappies",
    "00000000-0000-4000-8000-000000000016": "Baba-naelversorgingstel",
    "00000000-0000-4000-8000-000000000086": (
        "Grootte 2-doeke (ongeveer 3–8 kg)"
    ),
    "00000000-0000-4000-8000-000000000087": (
        "Grootte 3-doeke (ongeveer 7–13 kg)"
    ),
    "00000000-0000-4000-8000-000000000088": (
        "Grootte 4-doeke (ongeveer 9–14 kg)"
    ),
    "00000000-0000-4000-8000-000000000092": "Baba-afveedoekiehouer",
    "00000000-0000-4000-8000-000000000029": "Boudjiesalf",
    "00000000-0000-4000-8000-000000000030": "Geurvrye waspoeier",
    "00000000-0000-4000-8000-000000000058": "Baba-olie",
    "00000000-0000-4000-8000-000000000059": "Bababad of badsitplek",
    "00000000-0000-4000-8000-000000000060": "Digitale termometer",
    "00000000-0000-4000-8000-000000000062": (
        "Katoenblokkies of wattepluisies (slegs vir uitwendige gebruik)"
    ),
    "00000000-0000-4000-8000-000000000017": "Baba-kam-en-borselstel",
    "00000000-0000-4000-8000-000000000076": "Doekorganiseerder",
    "00000000-0000-4000-8000-000000000091": "Sagte babasjampoe",
    "00000000-0000-4000-8000-000000000047": (
        "Aqueous room vir baba (ongegeur)"
    ),
    "00000000-0000-4000-8000-000000000048": "Neusaspirator",
    "00000000-0000-4000-8000-000000000049": "Baba-waslappies",
    "44444444-4444-4444-8444-444444444444": (
        "Ongegeurde baba-afveedoekies (suiwer water verkies)"
    ),
    "00000000-0000-4000-8000-000000000031": "Sagte babalyfwasmiddel",
    "00000000-0000-4000-8000-000000000063": "Babygrows",
    "00000000-0000-4000-8000-000000000033": "0–3 maande somerklere",
    "00000000-0000-4000-8000-000000000034": "3–6 maande herfsklere",
    "00000000-0000-4000-8000-000000000035": (
        "6–12 maande winter- en lenteklere"
    ),
    "00000000-0000-4000-8000-000000000064": "Baba-handskoentjies",
    "00000000-0000-4000-8000-000000000065": "Truie, cardigans of baadjies",
    "00000000-0000-4000-8000-000000000036": "Babasokkies",
    "00000000-0000-4000-8000-000000000045": "Babamussies",
    "00000000-0000-4000-8000-000000000037": "Babaskoentjies met sagte sole",
    "22222222-2222-4222-8222-222222222222": "Baba-monitor",
    "00000000-0000-4000-8000-000000000010": "Slaapsakke",
    "00000000-0000-4000-8000-000000000044": "Inwikkeldoeke",
    "00000000-0000-4000-8000-000000000051": "Nagliggie",
    "00000000-0000-4000-8000-000000000066": "Beddegoed vir wieg of kot",
    "00000000-0000-4000-8000-000000000008": (
        "Waterdigte oortreksel vir standaard-kotmatras (ongeveer 118 × 56 cm)"
    ),
    "00000000-0000-4000-8000-000000000009": (
        "Paslakens vir standaard-kotmatras (ongeveer 118 × 56 cm)"
    ),
    "00000000-0000-4000-8000-000000000094": (
        "Waterdigte oortreksel vir standaard-kampkotmatras "
        "(ongeveer 970 × 670 mm)"
    ),
    "00000000-0000-4000-8000-000000000095": (
        "Paslakens vir standaard-kampkotmatras (ongeveer 970 × 670 mm)"
    ),
    "00000000-0000-4000-8000-000000000011": (
        "Babakomberse (vir gebruik onder toesig)"
    ),
    "00000000-0000-4000-8000-000000000014": "Doeksak",
    "00000000-0000-4000-8000-000000000012": "Doekomruilmat of -stasie",
    "00000000-0000-4000-8000-000000000018": "Veilige muskietnet",
    "00000000-0000-4000-8000-000000000038": "Badspeelgoed",
    "00000000-0000-4000-8000-000000000039": "Sagte speelgoed",
    "00000000-0000-4000-8000-000000000040": "Plastiekspeelgoed",
    "00000000-0000-4000-8000-000000000041": "Opvoedkundige speelgoed",
    "00000000-0000-4000-8000-000000000042": "Rattels en sensoriese speelgoed",
    "00000000-0000-4000-8000-000000000043": "Tandekry-speelgoed",
    "00000000-0000-4000-8000-000000000050": "Aktiwiteitspeelmat",
    "00000000-0000-4000-8000-000000000067": "Fopspeenhouers",
    "00000000-0000-4000-8000-000000000068": "Bababoeke",
    "00000000-0000-4000-8000-000000000069": "Babaklerehangers",
    "00000000-0000-4000-8000-000000000070": "Bêremandjies",
    "00000000-0000-4000-8000-000000000071": "Baba-winkelgeskenkbewyse",
    "00000000-0000-4000-8000-000000000072": "My Eerste Jaar-fotoalbum",
    "00000000-0000-4000-8000-000000000073": "Mylpaalkaartjies",
    "00000000-0000-4000-8000-000000000074": "Musiekboks of kotmobiel",
    "00000000-0000-4000-8000-000000000021": "Tepelroom",
    "00000000-0000-4000-8000-000000000019": (
        "Borsvoedingsbras (groot en ekstra groot)"
    ),
    "00000000-0000-4000-8000-000000000077": "Gemaklike huisklere",
    "00000000-0000-4000-8000-000000000082": (
        "’n Klein ontspanningsgeskenk vir Mamma"
    ),
    "00000000-0000-4000-8000-000000000085": "Sonskerm vir Mamma",
}

CUSTOM_ITEM_TITLES_AF = {
    "Baby Wrap/Carrier": "Baba-draadoek of -draer",
    "Baby bouncer with music": "Babawipstoel met musiek",
    "Breast Pump": "Borspomp",
}


@contextmanager
def database():
    database_url = os.environ.get("DATABASE_URL")
    if database_url:
        connection = psycopg.connect(
            database_url,
            row_factory=dict_row,
            connect_timeout=5,
        )
    else:
        connection = psycopg.connect(
            host=os.environ.get("REGISTRY_DB_HOST", "database"),
            dbname=os.environ.get("REGISTRY_DB_NAME", "registry"),
            user=os.environ.get("REGISTRY_DB_USER", "registry_app"),
            password=os.environ["REGISTRY_APP_DB_PASSWORD"],
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


def add_item_translations(items):
    translated_items = []
    for item in items:
        translated_item = dict(item)
        translated_item["title_af"] = ITEM_TITLES_AF.get(
            str(item["id"]),
            CUSTOM_ITEM_TITLES_AF.get(item["title"], item["title"]),
        )
        translated_items.append(translated_item)
    return translated_items


def item_title_af(item_id, item_title):
    return ITEM_TITLES_AF.get(
        str(item_id),
        CUSTOM_ITEM_TITLES_AF.get(item_title, item_title),
    )


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
                    "title_af": ITEM_GROUP_TITLES_AF[title],
                    "items": group_items_for_title,
                    "allows_custom_items": title == CUSTOM_ITEM_CATEGORY,
                    "note": ITEM_GROUP_NOTES.get(title),
                    "note_af": ITEM_GROUP_NOTES_AF.get(title),
                }
            )
            assigned_categories.update(categories)

    remaining_items = [
        item for item in items if item["category"] not in assigned_categories
    ]
    if remaining_items:
        grouped.append(
            {
                "title": "Other",
                "title_af": ITEM_GROUP_TITLES_AF["Other"],
                "items": remaining_items,
                "note": None,
                "note_af": None,
            }
        )

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
        item_groups=group_items(add_item_translations(list_items())),
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
            item_title_af=item_title_af(item_id, item_title),
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

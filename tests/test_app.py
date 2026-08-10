import importlib.util
import pathlib
import re
from datetime import date

import pytest


APP_PATH = pathlib.Path(__file__).parents[1] / "app.py"
SPEC = importlib.util.spec_from_file_location("registry_app", APP_PATH)
registry_app = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(registry_app)


@pytest.fixture()
def client(monkeypatch):
    monkeypatch.setattr(
        registry_app,
        "list_items",
        lambda: [
            {
                "id": "00000000-0000-4000-8000-000000000012",
                "title": "Changing mat or station",
                "description": "A test changing mat.",
                "category": "Changing and travel",
                "purchase_url": None,
                "claim_mode": "single",
                "claim_count": 0,
                "is_available": True,
                "max_claims": None,
                "display_order": 10,
            },
            {
                "id": "00000000-0000-4000-8000-000000000086",
                "title": "Size 2 nappies (approximately 3–8 kg)",
                "description": "Test nappies.",
                "category": "Care and bath",
                "purchase_url": None,
                "claim_mode": "multiple",
                "claim_count": 2,
                "is_available": True,
                "max_claims": 3,
                "display_order": 20,
            },
            {
                "id": "00000000-0000-4000-8000-000000000033",
                "title": "Clothing (0–3 months)",
                "description": "Test 0–3 month clothing.",
                "category": "Clothing",
                "purchase_url": None,
                "claim_mode": "multiple",
                "claim_count": 0,
                "is_available": True,
                "max_claims": None,
                "display_order": 30,
            },
            {
                "id": "00000000-0000-4000-8000-000000000038",
                "title": "Bath toys",
                "description": "Test bath toys.",
                "category": "Parents irritation",
                "purchase_url": None,
                "claim_mode": "multiple",
                "claim_count": 0,
                "is_available": True,
                "max_claims": None,
                "display_order": 40,
            },
            {
                "id": "00000000-0000-4000-8000-000000000099",
                "title": "Portable changing basket",
                "description": "Suggested by a registry visitor.",
                "category": "Things we might have missed",
                "purchase_url": None,
                "claim_mode": "single",
                "claim_count": 0,
                "is_available": True,
                "max_claims": None,
                "display_order": 1000,
            },
        ],
    )
    monkeypatch.setattr(
        registry_app,
        "baby_shower_status",
        lambda: {"days_remaining": 84, "is_today": False, "has_passed": False},
    )
    registry_app.app.config.update(TESTING=True)
    return registry_app.app.test_client()


def test_homepage_is_mobile_ready(client):
    response = client.get("/")
    assert response.status_code == 200
    assert b'name="viewport"' in response.data
    assert b"Changing mat or station" in response.data
    assert "Clothing (0–3 months)".encode() in response.data
    assert b'aria-level="2"\n            >Clothing</span>' in response.data
    assert b"Bath toys" in response.data
    assert b"Play &amp; other" in response.data
    assert b"Care &amp; bath" in response.data
    assert b"no newborn nappies, please" in response.data
    assert "Emilia-Rose’s Gift Registry".encode() in response.data
    assert b"emilia-rose-sheep-hero" not in response.data
    assert b"A little list for our little lamb" in response.data
    assert "baby shower on October 31st".encode() in response.data
    assert b"84</strong>" in response.data
    assert b"days remaining" in response.data
    assert b"Choose something" not in response.data
    assert b"No account is needed" not in response.data
    assert b"Manage my claims" not in response.data
    assert b"Baby Register for Emilia-Rose home" not in response.data
    assert b"Things we might have missed" in response.data
    assert b'action="/items/add"' in response.data
    assert b"Portable changing basket" in response.data
    assert b">Remove item</button>" in response.data
    assert b"/items/00000000-0000-4000-8000-000000000099/remove" in response.data
    assert b"/items/00000000-0000-4000-8000-000000000012/remove" not in response.data
    assert b"data-registry-item" in response.data
    assert b"2</strong> of 3 claimed" in response.data
    assert b"items</span>" not in response.data
    assert b"/items/00000000-0000-4000-8000-000000000086/unclaim" in response.data

    details_tags = re.findall(br"<details\b[^>]*>", response.data)
    assert details_tags
    assert all(b" open" in tag for tag in details_tags)
    assert response.data.count(b'<summary class="category-header">') == len(
        details_tags
    )


def test_claim_records_claim_without_showing_private_code(client, monkeypatch):
    monkeypatch.setattr(registry_app, "create_claim", lambda item_id, token: "claimed")

    response = client.post(
        "/items/00000000-0000-4000-8000-000000000012/claim",
        data={"item_title": "Changing mat or station"},
    )

    assert response.status_code == 201
    assert b"Claim recorded" in response.data
    assert b"data-store-token" in response.data
    assert b"data-item-id" in response.data
    assert b"Private undo code" not in response.data
    assert b"Undo this claim" not in response.data


def test_second_single_claim_redirects_with_notice(client, monkeypatch):
    monkeypatch.setattr(
        registry_app,
        "create_claim",
        lambda item_id, token: "already_claimed",
    )

    response = client.post(
        "/items/00000000-0000-4000-8000-000000000012/claim",
        follow_redirects=False,
    )

    assert response.status_code == 303
    assert "notice=already_claimed" in response.headers["Location"]


def test_limited_item_rejects_claim_after_limit(client, monkeypatch):
    monkeypatch.setattr(
        registry_app,
        "create_claim",
        lambda item_id, token: "claim_limit_reached",
    )

    response = client.post(
        "/items/00000000-0000-4000-8000-000000000086/claim",
        follow_redirects=False,
    )

    assert response.status_code == 303
    assert "notice=claim_limit_reached" in response.headers["Location"]


def test_custom_item_is_added_and_redirected_to_it(client, monkeypatch):
    item_id = "00000000-0000-4000-8000-000000000099"
    captured = {}

    def fake_add_custom_item(title):
        captured["title"] = title
        return item_id

    monkeypatch.setattr(registry_app, "add_custom_item", fake_add_custom_item)

    response = client.post(
        "/items/add",
        data={"title": "  Portable   changing basket  "},
        follow_redirects=False,
    )

    assert response.status_code == 303
    assert captured["title"] == "Portable changing basket"
    assert "notice=custom_item_added" in response.headers["Location"]
    assert response.headers["Location"].endswith(f"#item-{item_id}")


def test_invalid_custom_item_is_rejected(client, monkeypatch):
    def fail_if_called(title):
        raise AssertionError("Invalid title should not reach the database")

    monkeypatch.setattr(registry_app, "add_custom_item", fail_if_called)

    response = client.post(
        "/items/add",
        data={"title": " "},
        follow_redirects=False,
    )

    assert response.status_code == 303
    assert "notice=invalid_custom_item" in response.headers["Location"]


def test_custom_item_can_be_removed(client, monkeypatch):
    monkeypatch.setattr(registry_app, "remove_custom_item", lambda item_id: True)

    response = client.post(
        "/items/00000000-0000-4000-8000-000000000099/remove",
        follow_redirects=False,
    )

    assert response.status_code == 303
    assert "notice=custom_item_removed" in response.headers["Location"]
    assert response.headers["Location"].endswith("#missed-items")


def test_standard_item_cannot_be_removed(client, monkeypatch):
    monkeypatch.setattr(registry_app, "remove_custom_item", lambda item_id: False)

    response = client.post(
        "/items/00000000-0000-4000-8000-000000000012/remove",
        follow_redirects=False,
    )

    assert response.status_code == 303
    assert "notice=item_not_removable" in response.headers["Location"]


def test_baby_shower_countdown():
    assert registry_app.baby_shower_status(date(2026, 10, 30)) == {
        "days_remaining": 1,
        "is_today": False,
        "has_passed": False,
    }
    assert registry_app.baby_shower_status(date(2026, 10, 31)) == {
        "days_remaining": 0,
        "is_today": True,
        "has_passed": False,
    }
    assert registry_app.baby_shower_status(date(2026, 11, 1)) == {
        "days_remaining": 0,
        "is_today": False,
        "has_passed": True,
    }


def test_for_mom_note_uses_generic_label():
    assert registry_app.ITEM_GROUP_NOTES["For Mom"] == (
        "A few thoughtful comforts for Mom."
    )


def test_valid_undo_releases_claim(client, monkeypatch):
    monkeypatch.setattr(registry_app, "release_claim", lambda token: True)

    response = client.post(
        "/claims/undo",
        data={"undo_token": "example-private-token"},
    )

    assert response.status_code == 200
    assert b"Claim undone" in response.data


def test_empty_undo_token_is_rejected(client):
    response = client.post("/claims/undo", data={"undo_token": ""})
    assert response.status_code == 400


def test_public_unclaim_releases_one_claim(client, monkeypatch):
    monkeypatch.setattr(registry_app, "release_one_claim_for_item", lambda item_id: True)

    response = client.post(
        "/items/00000000-0000-4000-8000-000000000012/unclaim",
        follow_redirects=False,
    )

    assert response.status_code == 303
    assert "notice=unclaimed" in response.headers["Location"]

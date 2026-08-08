#!/usr/bin/env python3
import html
import re
import sys
import urllib.error
import urllib.parse
import urllib.request


BASE_URL = "http://127.0.0.1:8080"
SINGLE_ITEM = "00000000-0000-4000-8000-000000000012"
MULTIPLE_ITEM = "00000000-0000-4000-8000-000000000053"
TOKEN_PATTERN = re.compile(r'data-store-token="([^"]+)"')


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, request, file_pointer, code, message, headers, new_url):
        return None


no_redirect = urllib.request.build_opener(NoRedirect)


def get(path):
    with urllib.request.urlopen(BASE_URL + path, timeout=5) as response:
        return response.status, response.read().decode("utf-8")


def post(path, values):
    body = urllib.parse.urlencode(values).encode("utf-8")
    request = urllib.request.Request(
        BASE_URL + path,
        data=body,
        headers={"Content-Type": "application/x-www-form-urlencoded"},
    )
    try:
        with no_redirect.open(request, timeout=5) as response:
            return response.status, response.read().decode("utf-8"), response.headers
    except urllib.error.HTTPError as error:
        return error.code, error.read().decode("utf-8"), error.headers


def claim(item_id, title):
    status, body, _ = post(
        f"/items/{item_id}/claim",
        {"item_title": title},
    )
    assert status == 201, f"Expected claim status 201, received {status}"
    match = TOKEN_PATTERN.search(body)
    assert match, "Claim response did not contain an undo token"
    return html.unescape(match.group(1))


def undo(token):
    status, body, _ = post("/claims/undo", {"undo_token": token})
    assert status == 200, f"Expected undo status 200, received {status}"
    assert "Claim undone" in body, "Undo response did not confirm release"


def main():
    cleanup_tokens = []
    try:
        status, body = get("/health")
        assert status == 200 and '"ok"' in body

        status, body = get("/")
        assert status == 200 and "Baby Register for Emilia-Rose" in body

        single_token = claim(SINGLE_ITEM, "Changing mat or station")
        cleanup_tokens.append(single_token)

        status, _, headers = post(
            f"/items/{SINGLE_ITEM}/claim",
            {"item_title": "Changing mat or station"},
        )
        assert status == 303
        assert "notice=already_claimed" in headers["Location"]

        multi_token_one = claim(MULTIPLE_ITEM, "Size 1 nappies")
        cleanup_tokens.append(multi_token_one)
        multi_token_two = claim(MULTIPLE_ITEM, "Size 1 nappies")
        cleanup_tokens.append(multi_token_two)

        undo(single_token)
        cleanup_tokens.remove(single_token)

        replacement_token = claim(SINGLE_ITEM, "Changing mat or station")
        cleanup_tokens.append(replacement_token)

        status, _, headers = post(f"/items/{SINGLE_ITEM}/unclaim", {})
        assert status == 303
        assert "notice=unclaimed" in headers["Location"]
        cleanup_tokens.remove(replacement_token)
    finally:
        for token in cleanup_tokens:
            try:
                undo(token)
            except Exception:
                pass

    print(
        "PASS: health, single claim, duplicate rejection, multi-claim, "
        "token undo, and public unclaim"
    )


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        print(f"FAIL: {error}", file=sys.stderr)
        raise

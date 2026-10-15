import assert from "node:assert/strict";
import test from "node:test";
import catalogue from "../src/catalogue.generated.json" with { type: "json" };
import { claimDocumentId, countClaims, groupItems, type CatalogueItem } from "../src/model.ts";

const items = catalogue as CatalogueItem[];

test("catalogue preserves the final migrated registry", () => {
  assert.equal(items.length, 75);
  assert.equal(new Set(items.map((item) => item.id)).size, 75);
  assert(items.some((item) => item.title.includes("standard cot mattress") && item.title.includes("Waterproof cover")));
  assert(items.some((item) => item.title.includes("camp-cot mattress") && item.title.includes("Fitted sheets")));
  assert(!items.some((item) => item.title === "Standard cot mattress"));
});

test("catalogue groups include an empty visitor suggestion section", () => {
  const groups = groupItems(items);
  assert.deepEqual(groups.map((group) => group.title), ["Feeding", "Care & bath", "Clothing", "Sleep", "Out & about", "Play & other", "For Mom", "Things we might have missed"]);
  assert.equal(groups.at(-1)?.allowsCustomItems, true);
});

test("claim identifiers enforce one single or multiple claim per browser", () => {
  const single = items.find((item) => item.claimMode === "single" && item.maxClaims === null)!;
  const multiple = items.find((item) => item.claimMode === "multiple" && item.maxClaims === null)!;
  assert.equal(claimDocumentId(single, "visitor"), `s_${single.id}`);
  assert.equal(claimDocumentId(multiple, "visitor"), `m_${multiple.id}_visitor`);
  assert.equal(claimDocumentId({ ...single, maxClaims: 3 }, "visitor", 2), `l_${single.id}_2`);
  assert.equal(countClaims([{ id: "one", itemId: single.id, ownerUid: "visitor", kind: "single", slot: null }], single.id), 1);
});

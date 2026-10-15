import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test, { after, before } from "node:test";
import { serverTimestamp } from "firebase/firestore";
import { assertFails, assertSucceeds, initializeTestEnvironment } from "@firebase/rules-unit-testing";

const singleItem = "22222222-2222-4222-8222-222222222222";
const multipleItem = "00000000-0000-4000-8000-000000000010";
const limitedItem = "00000000-0000-4000-8000-000000000092";
let environment;

const claim = (itemId, ownerUid, kind, slot = null) => ({ itemId, ownerUid, kind, slot, createdAt: serverTimestamp() });

before(async () => {
  environment = await initializeTestEnvironment({
    projectId: "demo-registry",
    firestore: { rules: await readFile(new URL("../firestore.rules", import.meta.url), "utf8") },
  });
});

after(async () => environment?.cleanup());

test("only authenticated visitors can read claims", async () => {
  await assertSucceeds(environment.authenticatedContext("visitor").firestore().collection("claims").get());
  await assertFails(environment.unauthenticatedContext().firestore().collection("claims").get());
});

test("single and multiple claims have constrained identifiers and ownership", async () => {
  const owner = environment.authenticatedContext("owner").firestore();
  const other = environment.authenticatedContext("other").firestore();
  const singleRef = owner.doc(`claims/s_${singleItem}`);
  await assertSucceeds(singleRef.set(claim(singleItem, "owner", "single")));
  await assertFails(other.doc(`claims/s_${singleItem}`).delete());
  await assertSucceeds(singleRef.delete());
  await assertSucceeds(owner.doc(`claims/m_${multipleItem}_owner`).set(claim(multipleItem, "owner", "multiple")));
  await assertFails(owner.doc(`claims/m_${multipleItem}_wrong`).set(claim(multipleItem, "owner", "multiple")));
  await assertFails(owner.doc("claims/s_not-an-item").set(claim("not-an-item", "owner", "single")));
});

test("limited claims cannot create more slots than the catalogue permits", async () => {
  const owner = environment.authenticatedContext("limited-owner").firestore();
  for (let slot = 0; slot < 3; slot += 1) {
    await assertSucceeds(owner.doc(`claims/l_${limitedItem}_${slot}`).set(claim(limitedItem, "limited-owner", "limited", slot)));
  }
  await assertFails(owner.doc(`claims/l_${limitedItem}_3`).set(claim(limitedItem, "limited-owner", "limited", 3)));
});

test("visitor suggestions remain owner-controlled and cannot be removed while claimed", async () => {
  const owner = environment.authenticatedContext("suggestor").firestore();
  const other = environment.authenticatedContext("other-suggestor").firestore();
  const item = owner.doc("customItems/custom-one");
  await assertSucceeds(item.set({ title: "Bottle drying rack", ownerUid: "suggestor", createdAt: serverTimestamp() }));
  await assertFails(other.doc("customItems/custom-one").delete());
  const claimRef = other.doc("claims/c_custom-one");
  await assertSucceeds(claimRef.set(claim("custom-one", "other-suggestor", "custom")));
  await assertFails(item.delete());
  await assertSucceeds(claimRef.delete());
  await assertSucceeds(item.delete());
  assert.equal((await item.get()).exists, false);
});

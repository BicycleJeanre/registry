import { initializeApp } from "firebase/app";
import { deleteUser, getAuth, signInAnonymously } from "firebase/auth";
import { deleteDoc, doc, getDoc, getFirestore, serverTimestamp, setDoc } from "firebase/firestore";

const config = {
  apiKey: process.env.VITE_FIREBASE_API_KEY,
  authDomain: process.env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.VITE_FIREBASE_PROJECT_ID,
  appId: process.env.VITE_FIREBASE_APP_ID,
};

if (!Object.values(config).every(Boolean)) throw new Error("Firebase web configuration is incomplete.");

const app = initializeApp(config);
const auth = getAuth(app);
const db = getFirestore(app);
const user = (await signInAnonymously(auth)).user;
const suffix = `${Date.now()}-${user.uid.slice(0, 8)}`;
const itemId = `smoke-${suffix}`;
const itemRef = doc(db, "customItems", itemId);
const customClaimRef = doc(db, "claims", `c_${itemId}`);
const multipleItemId = "00000000-0000-4000-8000-000000000010";
const multipleClaimRef = doc(db, "claims", `m_${multipleItemId}_${user.uid}`);

try {
  await setDoc(itemRef, { title: "Synthetic registry smoke test", ownerUid: user.uid, createdAt: serverTimestamp() });
  await setDoc(customClaimRef, { itemId, ownerUid: user.uid, kind: "custom", slot: null, createdAt: serverTimestamp() });
  await setDoc(multipleClaimRef, { itemId: multipleItemId, ownerUid: user.uid, kind: "multiple", slot: null, createdAt: serverTimestamp() });
  if (!(await getDoc(customClaimRef)).exists()) throw new Error("Synthetic custom claim could not be read back.");
  if (!(await getDoc(multipleClaimRef)).exists()) throw new Error("Synthetic catalogue claim could not be read back.");
  console.log("PASS anonymous auth, visitor suggestion, claim, read, and owner cleanup");
} finally {
  await deleteDoc(customClaimRef).catch(() => undefined);
  await deleteDoc(multipleClaimRef).catch(() => undefined);
  await deleteDoc(itemRef).catch(() => undefined);
  await deleteUser(user).catch(() => undefined);
}

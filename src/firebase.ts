import { initializeApp } from "firebase/app";
import { getAuth, onAuthStateChanged, signInAnonymously, type User } from "firebase/auth";
import {
  collection,
  connectFirestoreEmulator,
  deleteDoc,
  doc,
  initializeFirestore,
  onSnapshot,
  persistentLocalCache,
  persistentMultipleTabManager,
  runTransaction,
  serverTimestamp,
  setDoc,
  type Unsubscribe,
} from "firebase/firestore";
import type { CatalogueItem, Claim } from "./model";
import { claimDocumentId } from "./model";

const config = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
  appId: import.meta.env.VITE_FIREBASE_APP_ID,
};

export const configured = Object.values(config).every(Boolean);
const app = configured ? initializeApp(config) : null;
const auth = app ? getAuth(app) : null;
const db = app
  ? initializeFirestore(app, {
      localCache: persistentLocalCache({ tabManager: persistentMultipleTabManager() }),
    })
  : null;

if (import.meta.env.VITE_USE_EMULATORS === "true" && auth && db) {
  connectFirestoreEmulator(db, "127.0.0.1", 8080);
}

let currentUser: User | null = null;
let authReady: Promise<User> | null = null;

export function ensureAnonymousUser(): Promise<User> {
  if (!auth) return Promise.reject(new Error("The registry database is not configured."));
  if (currentUser) return Promise.resolve(currentUser);
  if (authReady) return authReady;
  authReady = new Promise<User>((resolve, reject) => {
    const stop = onAuthStateChanged(auth, async (user) => {
      if (user) {
        currentUser = user;
        stop();
        resolve(user);
        return;
      }
      try {
        await signInAnonymously(auth);
      } catch (error) {
        stop();
        reject(error);
      }
    }, reject);
  });
  return authReady;
}

export function watchRegistry(
  onClaims: (claims: Claim[]) => void,
  onCustomItems: (items: CatalogueItem[]) => void,
  onError: (message: string) => void,
): () => void {
  const stops: Unsubscribe[] = [];
  if (!db) return () => undefined;
  stops.push(onSnapshot(collection(db, "claims"), (snapshot) => {
    onClaims(snapshot.docs.map((entry) => ({ id: entry.id, ...entry.data() }) as Claim));
  }, () => onError("Could not load current claims. Please check your connection.")));
  stops.push(onSnapshot(collection(db, "customItems"), (snapshot) => {
    onCustomItems(snapshot.docs.map((entry) => {
      const data = entry.data();
      return {
        id: entry.id,
        title: data.title,
        titleAf: data.title,
        description: "Suggested by a registry visitor.",
        category: "Things we might have missed",
        claimMode: "single",
        maxClaims: null,
        displayOrder: 900,
        custom: true,
        ownerUid: data.ownerUid,
      } as CatalogueItem;
    }));
  }, () => onError("Could not load visitor suggestions. Please check your connection.")));
  return () => stops.forEach((stop) => stop());
}

export async function claimItem(item: CatalogueItem): Promise<void> {
  if (!db) throw new Error("The registry database is not configured.");
  const user = await ensureAnonymousUser();
  await runTransaction(db, async (transaction) => {
    let slot: number | undefined;
    let reference;
    if (item.maxClaims !== null) {
      const candidates = Array.from({ length: item.maxClaims }, (_, index) => doc(db, "claims", claimDocumentId(item, user.uid, index)));
      const snapshots = [];
      for (const candidate of candidates) snapshots.push(await transaction.get(candidate));
      const available = snapshots.findIndex((snapshot) => !snapshot.exists());
      if (available < 0) throw new Error("That item has reached its claim limit.");
      slot = available;
      reference = candidates[available];
    } else {
      reference = doc(db, "claims", claimDocumentId(item, user.uid));
      if ((await transaction.get(reference)).exists()) throw new Error("You have already covered this item.");
    }
    transaction.set(reference, {
      itemId: item.id,
      ownerUid: user.uid,
      kind: item.custom ? "custom" : item.maxClaims !== null ? "limited" : item.claimMode,
      slot: slot ?? null,
      createdAt: serverTimestamp(),
    });
  });
}

export async function unclaimItem(claim: Claim): Promise<void> {
  if (!db) throw new Error("The registry database is not configured.");
  const user = await ensureAnonymousUser();
  if (claim.ownerUid !== user.uid) throw new Error("Only the person who claimed this item can undo it.");
  await deleteDoc(doc(db, "claims", claim.id));
}

export async function addCustomItem(title: string): Promise<void> {
  if (!db) throw new Error("The registry database is not configured.");
  const user = await ensureAnonymousUser();
  const reference = doc(collection(db, "customItems"));
  await setDoc(reference, { title, ownerUid: user.uid, createdAt: serverTimestamp() });
}

export async function removeCustomItem(item: CatalogueItem): Promise<void> {
  if (!db) throw new Error("The registry database is not configured.");
  const user = await ensureAnonymousUser();
  if (item.ownerUid !== user.uid) throw new Error("Only the person who suggested this item can remove it.");
  await deleteDoc(doc(db, "customItems", item.id));
}

export function activeUserId(): string | null {
  return currentUser?.uid ?? null;
}

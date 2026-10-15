import catalogueData from "./catalogue.generated.json";
import type { CatalogueItem, Claim, Language } from "./model";
import { countClaims, groupItems } from "./model";
import {
  activeUserId,
  addCustomItem,
  claimItem,
  configured,
  ensureAnonymousUser,
  removeCustomItem,
  unclaimItem,
  watchRegistry,
} from "./firebase";
import "../static/styles.css";

const catalogue = catalogueData as CatalogueItem[];
const app = document.querySelector<HTMLElement>("#app")!;
const languageToggle = document.querySelector<HTMLButtonElement>("#language-toggle")!;
const languageToggleLabel = document.querySelector<HTMLElement>("#language-toggle-label")!;
const showerDate = new Date("2026-10-31T00:00:00+02:00");

let language: Language = localStorage.getItem("emilia-rose-registry-language") === "af" ? "af" : "en";
let claims: Claim[] = [];
let customItems: CatalogueItem[] = [];
let loading = true;
let busyItem = "";
let notice: { kind: "success" | "warning"; en: string; af: string } | null = null;

const text = (en: string, af: string) => language === "af" ? af : en;
const escapeHtml = (value: string) => value
  .replaceAll("&", "&amp;")
  .replaceAll("<", "&lt;")
  .replaceAll(">", "&gt;")
  .replaceAll('"', "&quot;")
  .replaceAll("'", "&#039;");

function countdown(): string {
  const now = new Date();
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const days = Math.ceil((showerDate.getTime() - today.getTime()) / 86_400_000);
  if (days < 0) return text("The celebration has arrived", "Die viering het aangebreek");
  if (days === 0) return text("It’s today!", "Dis vandag!");
  return `<strong>${days}</strong> ${text(days === 1 ? "day remaining" : "days remaining", days === 1 ? "dag oor" : "dae oor")}`;
}

function itemStatus(item: CatalogueItem, itemClaims: Claim[]): string {
  const count = itemClaims.length;
  if (item.maxClaims !== null) return `<strong class="claim-count">${count}</strong> ${text(`of ${item.maxClaims} claimed`, `van ${item.maxClaims} opgeëis`)}`;
  if (item.claimMode === "multiple") return `<strong class="claim-count">${count}</strong> ${text("claimed · more welcome", "opgeëis · nog is welkom")}`;
  return count === 0 ? text("Available", "Beskikbaar") : text("Covered", "Gedek");
}

function itemMarkup(item: CatalogueItem): string {
  const itemClaims = claims.filter((claim) => claim.itemId === item.id);
  const count = itemClaims.length;
  const available = item.maxClaims !== null ? count < item.maxClaims : item.claimMode === "multiple" || count === 0;
  const ownClaim = itemClaims.find((claim) => claim.ownerUid === activeUserId());
  const canRemove = item.custom && item.ownerUid === activeUserId() && count === 0;
  const title = text(item.title, item.titleAf);
  return `
    <article class="item-row${available ? "" : " item-row-claimed"}" id="item-${escapeHtml(item.id)}">
      <div class="item-summary">
        <h3>${escapeHtml(title)}</h3>
        <p>${itemStatus(item, itemClaims)}</p>
      </div>
      <div class="item-action">
        ${available ? `<button class="button button-primary button-compact" data-claim="${escapeHtml(item.id)}" ${busyItem === item.id || !configured ? "disabled" : ""}>${text("I can get this", "Ek kan dit kry")}</button>` : `<span class="covered-label">${text(item.maxClaims !== null ? "Limit reached ✓" : "Covered ✓", item.maxClaims !== null ? "Limiet bereik ✓" : "Gedek ✓")}</span>`}
        ${ownClaim ? `<button class="unclaim-button" data-unclaim="${escapeHtml(ownClaim.id)}">${text("Unclaim", "Maak eis ongedaan")}</button>` : ""}
        ${canRemove ? `<button class="remove-item-button" data-remove="${escapeHtml(item.id)}">${text("Remove item", "Verwyder item")}</button>` : ""}
      </div>
    </article>`;
}

function render(): void {
  document.documentElement.lang = language;
  document.title = text("Baby Register for Emilia-Rose", "Babaregister vir Emilia-Rose");
  languageToggle.setAttribute("aria-pressed", String(language === "af"));
  languageToggle.setAttribute("aria-label", text("Switch to Afrikaans", "Skakel oor na Engels"));
  languageToggleLabel.textContent = text("Afrikaans", "English");

  const groups = groupItems([...catalogue, ...customItems]);
  app.innerHTML = `
    <section class="hero">
      <div class="hero-copy">
        <span class="brand-mark" aria-hidden="true">♡</span>
        <h1 class="registry-title">${text("Emilia-Rose’s Gift Registry", "Emilia-Rose se Geskenkregister")}</h1>
        <p>${text("A little list for our little lamb.", "’n Klein lysie vir ons klein lammetjie.")}</p>
      </div>
    </section>
    <section class="event-summary" aria-label="${text("Baby shower date", "Datum van ooievaarstee")}">
      <p class="event-copy">${text("This registry is for Emilia-Rose’s baby shower on October 31st.", "Hierdie register is vir Emilia-Rose se ooievaarstee op 31 Oktober.")}</p>
      <p class="event-countdown">${countdown()}</p>
    </section>
    ${!configured ? `<div class="notice notice-warning" role="status">${text("The registry database has not been connected yet. Items are visible, but claiming is temporarily unavailable.", "Die registerdatabasis is nog nie gekoppel nie. Items is sigbaar, maar opeising is tydelik nie beskikbaar nie.")}</div>` : ""}
    ${loading && configured ? `<div class="notice notice-neutral" role="status">${text("Loading current availability…", "Huidige beskikbaarheid laai…")}</div>` : ""}
    ${notice ? `<div class="notice notice-${notice.kind}" role="status">${text(notice.en, notice.af)}</div>` : ""}
    <section class="category-stack" aria-label="${text("Registry items", "Registeritems")}">
      ${groups.map((group, index) => `
        <details class="category-card" ${index < 2 ? "open" : ""} ${group.allowsCustomItems ? 'id="missed-items"' : ""}>
          <summary class="category-header">
            <span class="category-header-copy">
              <span class="category-title" role="heading" aria-level="2">${escapeHtml(text(group.title, group.titleAf))}</span>
              ${group.note ? `<span class="category-note">${escapeHtml(text(group.note, group.noteAf!))}</span>` : ""}
            </span>
            <span class="category-toggle" aria-hidden="true"></span>
          </summary>
          <div class="item-list">${group.items.map(itemMarkup).join("")}</div>
          ${group.allowsCustomItems ? `
            <form class="custom-item-form" id="custom-item-form">
              <label class="custom-item-label" for="custom-item-title">${text("Add something we missed", "Voeg iets by wat ons gemis het")}</label>
              <div class="custom-item-controls">
                <input class="custom-item-input" id="custom-item-title" name="title" type="text" minlength="2" maxlength="120" placeholder="${text("Item name", "Itemnaam")}" autocomplete="off" required />
                <button class="button button-primary" type="submit" ${!configured ? "disabled" : ""}>${text("Add item", "Voeg item by")}</button>
              </div>
            </form>` : ""}
        </details>`).join("")}
    </section>`;

  document.querySelectorAll<HTMLButtonElement>("[data-claim]").forEach((button) => button.addEventListener("click", () => void performClaim(button.dataset.claim!)));
  document.querySelectorAll<HTMLButtonElement>("[data-unclaim]").forEach((button) => button.addEventListener("click", () => void performUnclaim(button.dataset.unclaim!)));
  document.querySelectorAll<HTMLButtonElement>("[data-remove]").forEach((button) => button.addEventListener("click", () => void performRemove(button.dataset.remove!)));
  document.querySelector<HTMLFormElement>("#custom-item-form")?.addEventListener("submit", (event) => void performAdd(event));
}

function showError(error: unknown): void {
  notice = { kind: "warning", en: error instanceof Error ? error.message : "Something went wrong. Please try again.", af: "Iets het verkeerd geloop. Probeer asseblief weer." };
  busyItem = "";
  render();
}

async function performClaim(itemId: string): Promise<void> {
  const item = [...catalogue, ...customItems].find((candidate) => candidate.id === itemId);
  if (!item) return;
  busyItem = itemId;
  notice = null;
  render();
  try {
    await claimItem(item);
    notice = { kind: "success", en: `Thank you — you’re getting ${item.title}.`, af: `Dankie — jy kry ${item.titleAf}.` };
  } catch (error) {
    showError(error);
  } finally {
    busyItem = "";
    render();
  }
}

async function performUnclaim(claimId: string): Promise<void> {
  const claim = claims.find((candidate) => candidate.id === claimId);
  if (!claim) return;
  try {
    await unclaimItem(claim);
    notice = { kind: "success", en: "Your claim was removed.", af: "Jou eis is verwyder." };
  } catch (error) {
    showError(error);
  }
}

async function performAdd(event: SubmitEvent): Promise<void> {
  event.preventDefault();
  const form = event.currentTarget as HTMLFormElement;
  const title = new FormData(form).get("title")?.toString().trim() ?? "";
  if (title.length < 2 || title.length > 120) return;
  try {
    await addCustomItem(title);
    form.reset();
    notice = { kind: "success", en: "Your item was added.", af: "Jou item is bygevoeg." };
  } catch (error) {
    showError(error);
  }
}

async function performRemove(itemId: string): Promise<void> {
  const item = customItems.find((candidate) => candidate.id === itemId);
  if (!item) return;
  try {
    await removeCustomItem(item);
    notice = { kind: "success", en: "The item was removed.", af: "Die item is verwyder." };
  } catch (error) {
    showError(error);
  }
}

languageToggle.addEventListener("click", () => {
  language = language === "en" ? "af" : "en";
  localStorage.setItem("emilia-rose-registry-language", language);
  render();
});

render();
if (configured) {
  ensureAnonymousUser()
    .then(() => {
      watchRegistry(
        (nextClaims) => { claims = nextClaims; loading = false; render(); },
        (nextItems) => { customItems = nextItems; render(); },
        (message) => showError(new Error(message)),
      );
    })
    .catch(showError);
}

export { catalogue, countClaims };

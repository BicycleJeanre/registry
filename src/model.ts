export type Language = "en" | "af";
export type ClaimMode = "single" | "multiple";

export interface CatalogueItem {
  id: string;
  title: string;
  titleAf: string;
  description: string;
  category: string;
  claimMode: ClaimMode;
  maxClaims: number | null;
  displayOrder: number;
  custom?: boolean;
  ownerUid?: string;
}

export interface Claim {
  id: string;
  itemId: string;
  ownerUid: string;
  kind: "single" | "multiple" | "limited" | "custom";
  slot: number | null;
}

export interface RegistryGroup {
  title: string;
  titleAf: string;
  note?: string;
  noteAf?: string;
  allowsCustomItems?: boolean;
  items: CatalogueItem[];
}

const groupDefinitions = [
  ["Feeding", "Voeding", ["Feeding"]],
  ["Care & bath", "Versorging en badtyd", ["Care and bath", "Bath and care", "Health and care", "Everyday essentials"]],
  ["Clothing", "Klere", ["Clothing"]],
  ["Sleep", "Slaap", ["Sleep", "Nursery"]],
  ["Out & about", "Op pad", ["Out and about", "Changing and travel", "Getting around"]],
  ["Play & other", "Speel en ander", ["Play and other", "Parents irritation"]],
  ["For Mom", "Vir Mamma", ["For Mom"]],
] as const;

export function groupItems(items: CatalogueItem[]): RegistryGroup[] {
  const groups: RegistryGroup[] = groupDefinitions.map(([title, titleAf, categories]) => ({
    title,
    titleAf,
    note: title === "Care & bath" ? "Nappies are welcome in sizes 2, 3 and 4 only — no newborn nappies, please." : title === "For Mom" ? "A few thoughtful comforts for Mom." : undefined,
    noteAf: title === "Care & bath" ? "Doeke is slegs welkom in groottes 2, 3 en 4 — geen pasgebore doeke nie, asseblief." : title === "For Mom" ? "’n Paar bedagsame bederfies vir Mamma." : undefined,
    items: items.filter((item) => (categories as readonly string[]).includes(item.category)),
  })).filter((group) => group.items.length > 0);

  groups.push({
    title: "Things we might have missed",
    titleAf: "Dinge wat ons dalk gemis het",
    allowsCustomItems: true,
    items: items.filter((item) => item.custom),
  });
  return groups;
}

export function claimDocumentId(item: CatalogueItem, uid: string, slot?: number): string {
  if (item.custom) return `c_${item.id}`;
  if (item.maxClaims !== null) {
    if (slot === undefined) throw new Error("A limited claim requires a slot.");
    return `l_${item.id}_${slot}`;
  }
  return item.claimMode === "single" ? `s_${item.id}` : `m_${item.id}_${uid}`;
}

export function countClaims(claims: Claim[], itemId: string): number {
  return claims.filter((claim) => claim.itemId === itemId).length;
}

# Emilia-Rose’s Gift Registry

A mobile-first, English/Afrikaans baby-shower registry deployed as a static GitHub Pages site with Firebase Anonymous Authentication and Cloud Firestore.

## Current behaviour

- The checked-in catalogue contains the 75 final active items recovered from the PostgreSQL migrations.
- Claims begin empty because the retired server’s Docker volume could not be recovered.
- Single items accept one claim globally.
- Unlimited items accept one claim per anonymous browser identity.
- Limited items use fixed Firestore claim slots, preventing claims above the configured limit.
- Visitors can undo only their own claims.
- Visitor suggestions can be removed only by their creator and only while unclaimed.
- No names, email addresses, or other personal details are requested.

## Local development

Copy `.env.example` to `.env.local` and add the Firebase web configuration, then:

```sh
npm install
npm run dev
```

Build and run local tests:

```sh
npm test
npm run test:rules
npm run build
```

The Firestore rules test requires Java for the Firebase emulator.

## Firebase setup

1. Use the dedicated Firebase project `emilia-rose-registry` and its registered web application.
2. Anonymous Authentication is enabled through `firebase.json`.
3. The standard, free-tier default Cloud Firestore database is in `nam5` with deletion protection enabled.
4. `firestore.rules` and `firestore.indexes.json` are deployed through the Firebase CLI.
5. Add the four `VITE_FIREBASE_*` values as GitHub Actions repository secrets.
6. Add `bicyclejeanre.github.io` and `registry.bicycleclouds.com` to Firebase Authentication’s authorized domains.

The Firebase web configuration identifies the Firebase project; it is not a service-account secret. Authorization is enforced by `firestore.rules`.

## GitHub Pages

The workflow in `.github/workflows/deploy-pages.yml` tests, builds, and deploys `dist/` whenever `main` changes. `public/CNAME` preserves the custom domain in every deployment.

Point the DNS record to GitHub Pages with:

```text
registry.bicycleclouds.com CNAME BicycleJeanre.github.io
```

Do not retain the old `A` record once the GitHub Pages custom domain is configured.

## Legacy source

The former Flask/PostgreSQL implementation and its migrations remain in this directory as recovery history. Vite builds only the new `index.html`, `src/`, and imported static assets.

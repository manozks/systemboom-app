# SYSTEMBOOM — Next.js

Next.js 15 (App Router, TypeScript) rebuild of the SYSTEMBOOM app. Static export, no server needed.

```bash
npm install
npm run dev          # http://localhost:3000
npm run build        # static site in ./out
NEXT_PUBLIC_BASE_PATH=/systemboom-app/next npm run build   # for GitHub Pages sub-path
```

Pages: `/` home, `/chats`, `/calls`, `/market`, `/profile`, `/design`, `/anonymous`.
Artwork is in `public/img` (all WebP). Layout is built in "design units" (941 per page width) so it scales to any phone width.

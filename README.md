# SYSTEMBOOM

- `/` — original HTML mobile prototype (index.html + assets/)
- `/next/` — Next.js build (source in `systemboom-next/`)
- `/app/` — Flutter web build of the app (source in `systemboom_flutter/`)

Live (GitHub Pages): https://manozks.github.io/systemboom-app/ https://manozks.github.io/systemboom-app/app/ and https://manozks.github.io/systemboom-app/next/

Rebuild the Flutter app: `cd systemboom_flutter && flutter build web --release --base-href /systemboom-app/app/`, then copy `build/web` to `app/`.

Next.js: `cd systemboom-next && NEXT_PUBLIC_BASE_PATH=/systemboom-app/next npm run build`, then copy `out/` to `next/`.

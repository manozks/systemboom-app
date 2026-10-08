# SYSTEMBOOM

- `/` — original HTML mobile prototype (index.html + assets/)
- `/app/` — Flutter web build of the app (source in `systemboom_flutter/`)

Live (GitHub Pages): https://manozks.github.io/systemboom-app/ and https://manozks.github.io/systemboom-app/app/

Rebuild the Flutter app: `cd systemboom_flutter && flutter build web --release --base-href /systemboom-app/app/`, then copy `build/web` to `app/`.

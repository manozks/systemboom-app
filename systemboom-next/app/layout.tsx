import type { Metadata, Viewport } from 'next';
import { ToastProvider } from '@/lib/ui';
import { StoreProvider } from '@/lib/data/store';
import { ConnectivityProvider } from '@/lib/connectivity';
import './globals.css';
import './kit.css';

const bp = process.env.NEXT_PUBLIC_BASE_PATH || '';

export const metadata: Metadata = {
  title: 'SYSTEMBOOM',
  description: 'SYSTEMBOOM — chats, calls and marketplace in one 3D metallic app.',
  icons: { icon: `${bp}/favicon.png`, apple: `${bp}/icon-192.png` },
};

export const viewport: Viewport = { themeColor: '#07090c', width: 'device-width', initialScale: 1, viewportFit: 'cover' };

// Asset URLs that must respect the GitHub Pages base path live here (plain CSS url() is not rewritten by Next).
const css = `
@font-face{font-family:'Figtree';src:url('${bp}/fonts/Figtree.ttf') format('truetype');font-weight:300 900;font-display:swap}
.stage{background-image:radial-gradient(120% 40% at 50% 0%,rgba(255,122,26,.08),transparent 60%),url('${bp}/img/carbon-tile.webp');background-size:auto,calc(18*var(--u)) calc(17*var(--u));background-repeat:no-repeat,repeat}
.thread .bubble{border-image-source:url('${bp}/img/chat-bubble.webp')}
.dialog.pf{border-image-source:url('${bp}/img/panel-frame.webp')}
.rowplate{border-image-source:url('${bp}/img/chat-bubble.webp')}
.pphoto{border-image-source:url('${bp}/img/pframe-photo.webp')}
.ptitle{border-image-source:url('${bp}/img/plate-title.webp')}
.prow{border-image-source:url('${bp}/img/plate-row.webp')}
.abtn.steel{border-image-source:url('${bp}/img/btn-steel.webp')}
.abtn.orange{border-image-source:url('${bp}/img/btn-orange.webp')}
.irow{border-image-source:url('${bp}/img/info-row.webp')}
.ncard{border-image-source:url('${bp}/img/notif-card.webp')}
.nbtn{border-image-source:url('${bp}/img/notif-btn.webp')}
.icta.orange{--bz:url('${bp}/img/info-cta-orange.webp')}
.icta.red{--bz:url('${bp}/img/info-cta-red.webp')}
.irow{--bz:url('${bp}/img/info-row.webp')}
.ichip.on{--bz:url('${bp}/img/info-chip-on.webp')}
.ichip.off{--bz:url('${bp}/img/info-chip-off.webp')}
.mp.dark{--bz:url('${bp}/img/plate-row.webp')}
.mp.mbtn{--bz:url('${bp}/img/btn-steel.webp')}
.mp.mbtn.on,.mp.pay{--bz:url('${bp}/img/btn-orange.webp')}
.mp.green{--bz:url('${bp}/img/plate-green.webp')}
.mp.pill{--bz:url('${bp}/img/pill-status.webp')}
.msheet .ering{background-image:url('${bp}/img/ring63-emoji.webp')}
.msheet .aring{background-image:url('${bp}/img/ring63-act.webp')}
.msheet .aring.red{background-image:url('${bp}/img/ring63-red.webp')}
.xbtn.primary,.xbtn.teal,.xbtn.sm.primary{--bz:url('${bp}/img/btn-orange.webp')}
.xbtn.steel{--bz:url('${bp}/img/btn-steel.webp')}
.xbtn.danger{--bz:url('${bp}/img/info-cta-red.webp')}
.ringart{background-image:url('${bp}/img/share-ring.webp')}
.thread .bubble.out{border-image-source:url('${bp}/img/chat-bubble-out.webp')}
`;

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <head>
        <style dangerouslySetInnerHTML={{ __html: css }} />
      </head>
      <body>
        <ToastProvider><ConnectivityProvider><StoreProvider>{children}</StoreProvider></ConnectivityProvider></ToastProvider>
      </body>
    </html>
  );
}

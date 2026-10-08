import type { Metadata, Viewport } from 'next';
import { ToastProvider } from '@/lib/ui';
import './globals.css';

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
`;

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <head>
        <style dangerouslySetInnerHTML={{ __html: css }} />
      </head>
      <body>
        <ToastProvider>{children}</ToastProvider>
      </body>
    </html>
  );
}

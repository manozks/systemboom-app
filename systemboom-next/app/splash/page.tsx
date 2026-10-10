'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';

export default function Splash() {
  const router = useRouter();
  useEffect(() => { const t = setTimeout(() => router.replace('/welcome/'), 2600); return () => clearTimeout(t); }, [router]);
  return (
    <div className="stage center-screen" onClick={() => router.replace('/welcome/')}>
      <div className="splashring" style={{ position: 'static', transform: 'none', animation: 'spinr 0.9s linear infinite' }} />
    </div>
  );
}

import Link from 'next/link';

export default function NotFound() {
  return (
    <div className="stage center-screen">
      <div>
        <div className="hero-title"><em>404</em></div>
        <p className="t-sub" style={{ margin: 'calc(20 * var(--u)) 0 calc(40 * var(--u))', color: '#c3cedb' }}>This page drifted off the grid.</p>
        <Link href="/" className="btn primary lg">Back home</Link>
      </div>
    </div>
  );
}

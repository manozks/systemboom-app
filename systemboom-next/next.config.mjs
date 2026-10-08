// Static export so the app can be hosted on GitHub Pages (set NEXT_PUBLIC_BASE_PATH=/systemboom-app/next for that).
const basePath = process.env.NEXT_PUBLIC_BASE_PATH || '';

/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'export',
  trailingSlash: true,
  basePath,
  assetPrefix: basePath || undefined,
  images: { unoptimized: true },
};

export default nextConfig;

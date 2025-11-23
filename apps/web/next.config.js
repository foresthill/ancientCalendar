/** @type {import('next').NextConfig} */
const nextConfig = {
  transpilePackages: ['@repo/calendar-core', '@repo/shared-types'],
};

module.exports = nextConfig;

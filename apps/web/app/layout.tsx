import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: '旧暦カレンダー | AncientCalendar',
  description: '新暦・旧暦統合カレンダー - 月のリズムを重視したカレンダー',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ja">
      <body className="min-h-screen bg-background antialiased">
        <div className="flex min-h-screen flex-col">
          <header className="border-b">
            <div className="container mx-auto flex h-14 items-center px-4">
              <h1 className="text-lg font-semibold">旧暦カレンダー</h1>
            </div>
          </header>
          <main className="flex-1 container mx-auto px-4 py-6">{children}</main>
        </div>
      </body>
    </html>
  );
}

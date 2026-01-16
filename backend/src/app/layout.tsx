export const metadata = {
  title: 'Devello iOS Backend',
  description: 'Backend API for Devello Studios iOS app',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}

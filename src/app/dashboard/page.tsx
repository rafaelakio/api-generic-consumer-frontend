'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/auth/useAuth';
import ApiTester from '@/components/features/ApiTester';
import Navbar from '@/components/features/Navbar';
import SessionBannerWrapper from '@/components/features/SessionBannerWrapper';

export default function DashboardPage() {
  const { user } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (user === null) router.replace('/login/');
  }, [user, router]);

  if (!user) return null;

  return (
    <div className="min-h-screen flex flex-col">
      <Navbar user={{ name: user.name, email: user.email }} />
      <SessionBannerWrapper />
      <main className="flex-1 container mx-auto px-4 py-8 max-w-7xl">
        <ApiTester />
      </main>
    </div>
  );
}

'use client';

import { useEffect } from 'react';
import { useCalendar } from '@/hooks/use-calendar';
import { CalendarGrid } from '@/components/calendar/calendar-grid';
import { MonthNavigator } from '@/components/calendar/month-navigator';
import { CalendarViewToggle } from '@/components/calendar/calendar-view-toggle';

export default function Home() {
  const {
    currentDate,
    calendarDates,
    view,
    setView,
    goToPreviousMonth,
    goToNextMonth,
    goToToday
  } = useCalendar();

  // 旧暦モードの時にダークテーマを適用
  useEffect(() => {
    if (view === 'lunar') {
      document.documentElement.classList.add('lunar-dark');
    } else {
      document.documentElement.classList.remove('lunar-dark');
    }
    return () => {
      document.documentElement.classList.remove('lunar-dark');
    };
  }, [view]);

  return (
    <div className="container mx-auto p-6 space-y-6 transition-colors duration-500">
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-bold">AncientCalendar</h1>
        <CalendarViewToggle view={view} onChange={setView} />
      </div>

      <MonthNavigator
        currentDate={currentDate}
        view={view}
        onPrevious={goToPreviousMonth}
        onNext={goToNextMonth}
        onToday={goToToday}
      />

      <CalendarGrid
        dates={calendarDates}
        currentMonth={currentDate}
        view={view}
      />
    </div>
  );
}

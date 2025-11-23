'use client';

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

  return (
    <div className="container mx-auto p-6 space-y-6">
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

'use client';

import { useState, useMemo } from 'react';
import { LunarConverter, CalendarDate } from '@repo/calendar-core';
import { startOfMonth, endOfMonth, eachDayOfInterval, startOfWeek, endOfWeek } from 'date-fns';

export type CalendarView = 'gregorian' | 'lunar';

export interface UseCalendarReturn {
  currentDate: Date;
  calendarDates: CalendarDate[];
  view: CalendarView;
  setCurrentDate: (date: Date) => void;
  setView: (view: CalendarView) => void;
  goToPreviousMonth: () => void;
  goToNextMonth: () => void;
  goToToday: () => void;
}

export function useCalendar(): UseCalendarReturn {
  const [currentDate, setCurrentDate] = useState(new Date());
  const [view, setView] = useState<CalendarView>('gregorian');

  const calendarDates = useMemo(() => {
    const monthStart = startOfMonth(currentDate);
    const monthEnd = endOfMonth(currentDate);
    const calendarStart = startOfWeek(monthStart, { weekStartsOn: 0 }); // 日曜日始まり
    const calendarEnd = endOfWeek(monthEnd, { weekStartsOn: 0 });

    const days = eachDayOfInterval({ start: calendarStart, end: calendarEnd });

    return days.map(day =>
      LunarConverter.gregorianToLunar(
        day.getFullYear(),
        day.getMonth() + 1,
        day.getDate()
      )
    );
  }, [currentDate]);

  const goToPreviousMonth = () => {
    setCurrentDate(prev => {
      const newDate = new Date(prev);
      newDate.setMonth(newDate.getMonth() - 1);
      return newDate;
    });
  };

  const goToNextMonth = () => {
    setCurrentDate(prev => {
      const newDate = new Date(prev);
      newDate.setMonth(newDate.getMonth() + 1);
      return newDate;
    });
  };

  const goToToday = () => {
    setCurrentDate(new Date());
  };

  return {
    currentDate,
    calendarDates,
    view,
    setCurrentDate,
    setView,
    goToPreviousMonth,
    goToNextMonth,
    goToToday
  };
}

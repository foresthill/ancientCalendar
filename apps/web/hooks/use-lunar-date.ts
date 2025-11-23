import { useMemo } from 'react';
import { LunarConverter, CalendarDate } from '@repo/calendar-core';

export function useLunarDate(date: Date): CalendarDate {
  return useMemo(() => {
    return LunarConverter.gregorianToLunar(
      date.getFullYear(),
      date.getMonth() + 1,
      date.getDate()
    );
  }, [date]);
}

export function useMonthDates(year: number, month: number): CalendarDate[] {
  return useMemo(() => {
    return LunarConverter.getMonthDates(year, month);
  }, [year, month]);
}

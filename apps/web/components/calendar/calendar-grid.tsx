'use client';

import { CalendarDate, LunarConverter } from '@repo/calendar-core';
import { DateCell } from './date-cell';
import { isSameMonth } from 'date-fns';

interface CalendarGridProps {
  dates: CalendarDate[];
  currentMonth: Date;
  view: 'gregorian' | 'lunar';
  onDateClick?: (date: CalendarDate) => void;
}

export function CalendarGrid({ dates, currentMonth, view, onDateClick }: CalendarGridProps) {
  const weekdays = view === 'gregorian'
    ? ['日', '月', '火', '水', '木', '金', '土']
    : ['初', '二', '三', '四', '五', '六', '七'];

  // 現在表示中の月を取得
  const currentGregorianMonth = currentMonth.getMonth() + 1;
  const lunarDate = LunarConverter.gregorianToLunar(
    currentMonth.getFullYear(),
    currentMonth.getMonth() + 1,
    1
  );
  const currentLunarMonth = lunarDate.lunar.month;

  return (
    <div className="w-full">
      {/* 曜日ヘッダー */}
      <div className="grid grid-cols-7 gap-1 mb-2">
        {weekdays.map((day, index) => (
          <div
            key={day}
            className={`text-center text-sm font-medium py-2 ${
              index === 0 ? 'text-red-500' : index === 6 ? 'text-blue-500' : ''
            }`}
          >
            {day}
          </div>
        ))}
      </div>

      {/* 日付グリッド */}
      <div className="grid grid-cols-7 gap-1">
        {dates.map((date, index) => {
          const gregorianDate = new Date(
            date.gregorian.year,
            date.gregorian.month - 1,
            date.gregorian.day
          );
          const isCurrentMonth = isSameMonth(gregorianDate, currentMonth);

          return (
            <DateCell
              key={index}
              date={date}
              view={view}
              isCurrentMonth={isCurrentMonth}
              currentGregorianMonth={currentGregorianMonth}
              currentLunarMonth={currentLunarMonth}
              onClick={() => onDateClick?.(date)}
            />
          );
        })}
      </div>
    </div>
  );
}

'use client';

import { CalendarDate } from '@repo/calendar-core';
import { MoonPhaseIndicator } from '../moon/moon-phase-indicator';
import { cn } from '@/lib/utils';

interface DateCellProps {
  date: CalendarDate;
  view: 'gregorian' | 'lunar';
  isCurrentMonth: boolean;
  onClick?: () => void;
}

export function DateCell({ date, view, isCurrentMonth, onClick }: DateCellProps) {
  const isToday = isDateToday(date);

  return (
    <button
      onClick={onClick}
      className={cn(
        'relative min-h-24 p-2 rounded-lg border transition-colors',
        'hover:bg-accent hover:border-accent-foreground',
        isCurrentMonth ? 'bg-background' : 'bg-muted/50 text-muted-foreground',
        isToday && 'ring-2 ring-primary'
      )}
    >
      <div className="flex flex-col items-start h-full">
        {/* 日付表示 */}
        <div className="flex items-center justify-between w-full">
          <span className={cn(
            'text-sm font-medium',
            isToday && 'text-primary font-bold'
          )}>
            {view === 'gregorian' ? date.gregorian.day : date.lunar.dayName}
          </span>

          {/* 月の画像 */}
          <MoonPhaseIndicator
            date={new Date(date.gregorian.year, date.gregorian.month - 1, date.gregorian.day)}
            size="sm"
          />
        </div>

        {/* 旧暦表示（新暦ビューの場合） */}
        {view === 'gregorian' && (
          <span className="text-xs text-muted-foreground mt-1">
            {date.lunar.dayName}
          </span>
        )}

        {/* 新暦表示（旧暦ビューの場合） */}
        {view === 'lunar' && (
          <span className="text-xs text-muted-foreground mt-1">
            {date.gregorian.day}
          </span>
        )}

        {/* 節気表示 */}
        {date.lunar.solarTerm && (
          <span className="text-xs text-amber-600 dark:text-amber-400 mt-auto">
            {date.lunar.solarTerm}
          </span>
        )}
      </div>
    </button>
  );
}

function isDateToday(date: CalendarDate): boolean {
  const today = new Date();
  return (
    date.gregorian.year === today.getFullYear() &&
    date.gregorian.month === today.getMonth() + 1 &&
    date.gregorian.day === today.getDate()
  );
}

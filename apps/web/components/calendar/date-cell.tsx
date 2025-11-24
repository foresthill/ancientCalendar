'use client';

import { CalendarDate } from '@repo/calendar-core';
import { MoonPhaseIndicator } from '../moon/moon-phase-indicator';
import { cn } from '@/lib/utils';

interface DateCellProps {
  date: CalendarDate;
  view: 'gregorian' | 'lunar';
  isCurrentMonth: boolean;
  currentGregorianMonth: number;
  currentLunarMonth: number;
  onClick?: () => void;
}

export function DateCell({ date, view, isCurrentMonth, currentGregorianMonth, currentLunarMonth, onClick }: DateCellProps) {
  const isToday = isDateToday(date);

  // 月が異なる場合のみ月を表示
  const showLunarMonth = date.lunar.month !== currentLunarMonth;
  const showGregorianMonth = date.gregorian.month !== currentGregorianMonth;

  // ヘッダーと同じ月かどうか（太字表示用）
  const isSameMonthAsHeader = view === 'gregorian' ? !showGregorianMonth : !showLunarMonth;

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
            'text-sm',
            isSameMonthAsHeader ? 'font-bold' : 'font-normal',
            isToday && 'text-primary'
          )}>
            {view === 'gregorian'
              ? (showGregorianMonth ? `${date.gregorian.month}/${date.gregorian.day}` : date.gregorian.day)
              : (showLunarMonth ? `${date.lunar.monthName}${date.lunar.dayName}` : date.lunar.dayName)
            }
          </span>

          {/* 月の画像 */}
          <MoonPhaseIndicator
            date={new Date(date.gregorian.year, date.gregorian.month - 1, date.gregorian.day)}
            size="sm"
          />
        </div>

        {/* 旧暦表示（新暦ビューの場合）- 常に月を表示 */}
        {view === 'gregorian' && (
          <span className="text-xs text-muted-foreground mt-1">
            {date.lunar.month}月{date.lunar.day}日
          </span>
        )}

        {/* 新暦表示（旧暦ビューの場合）- 常に月を表示 */}
        {view === 'lunar' && (
          <span className="text-xs text-muted-foreground mt-1">
            {date.gregorian.month}/{date.gregorian.day}
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

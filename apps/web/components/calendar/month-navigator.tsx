'use client';

import { Button } from '@/components/ui/button';
import { ChevronLeft, ChevronRight } from 'lucide-react';
import { LunarConverter } from '@repo/calendar-core';

interface MonthNavigatorProps {
  currentDate: Date;
  view: 'gregorian' | 'lunar';
  onPrevious: () => void;
  onNext: () => void;
  onToday: () => void;
}

export function MonthNavigator({
  currentDate,
  view,
  onPrevious,
  onNext,
  onToday
}: MonthNavigatorProps) {
  const formatMonth = () => {
    if (view === 'gregorian') {
      return {
        main: `${currentDate.getFullYear()}年 ${currentDate.getMonth() + 1}月`,
        sub: null
      };
    } else {
      // 旧暦表示 + グレゴリオ暦を付記
      const lunar = LunarConverter.gregorianToLunar(
        currentDate.getFullYear(),
        currentDate.getMonth() + 1,
        1
      );
      return {
        main: `${lunar.lunar.ganzhiYear}年 ${lunar.lunar.monthName}`,
        sub: `${currentDate.getFullYear()}年${currentDate.getMonth() + 1}月`
      };
    }
  };

  const monthDisplay = formatMonth();

  return (
    <div className="flex items-center justify-between">
      <div>
        <h2 className="text-2xl font-bold">{monthDisplay.main}</h2>
        {monthDisplay.sub && (
          <span className="text-sm text-muted-foreground">（{monthDisplay.sub}）</span>
        )}
      </div>

      <div className="flex items-center gap-2">
        <Button variant="outline" size="sm" onClick={onToday}>
          今日
        </Button>
        <Button variant="outline" size="icon" onClick={onPrevious}>
          <ChevronLeft className="h-4 w-4" />
        </Button>
        <Button variant="outline" size="icon" onClick={onNext}>
          <ChevronRight className="h-4 w-4" />
        </Button>
      </div>
    </div>
  );
}

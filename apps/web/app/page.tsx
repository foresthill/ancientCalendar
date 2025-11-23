'use client';

import { useState } from 'react';
import { format, startOfMonth, endOfMonth, eachDayOfInterval, getDay } from 'date-fns';
import { ja } from 'date-fns/locale';
import { LunarConverter, MoonPhaseCalculator } from '@repo/calendar-core';

type CalendarType = 'GREGORIAN' | 'LUNAR';

export default function HomePage() {
  const [currentDate, setCurrentDate] = useState(new Date());
  const [calendarType, setCalendarType] = useState<CalendarType>('GREGORIAN');

  const year = currentDate.getFullYear();
  const month = currentDate.getMonth() + 1;

  const monthStart = startOfMonth(currentDate);
  const monthEnd = endOfMonth(currentDate);
  const days = eachDayOfInterval({ start: monthStart, end: monthEnd });

  const startDayOfWeek = getDay(monthStart);
  const emptyDays = Array(startDayOfWeek).fill(null);

  const weekDays = ['日', '月', '火', '水', '木', '金', '土'];

  const prevMonth = () => {
    setCurrentDate(new Date(year, month - 2, 1));
  };

  const nextMonth = () => {
    setCurrentDate(new Date(year, month, 1));
  };

  const toggleCalendarType = () => {
    setCalendarType(calendarType === 'GREGORIAN' ? 'LUNAR' : 'GREGORIAN');
  };

  const today = LunarConverter.today();
  const todayMoon = MoonPhaseCalculator.today();

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <button
            onClick={prevMonth}
            className="px-3 py-1 border rounded hover:bg-muted"
          >
            ←
          </button>
          <h2 className="text-xl font-semibold">
            {format(currentDate, 'yyyy年M月', { locale: ja })}
          </h2>
          <button
            onClick={nextMonth}
            className="px-3 py-1 border rounded hover:bg-muted"
          >
            →
          </button>
        </div>
        <button
          onClick={toggleCalendarType}
          className="px-4 py-2 border rounded hover:bg-muted"
        >
          {calendarType === 'GREGORIAN' ? '旧暦に切替' : '新暦に切替'}
        </button>
      </div>

      <div className="p-4 border rounded-lg bg-muted/50">
        <div className="flex items-center gap-4">
          <div className="text-center">
            <img
              src={todayMoon.imagePath}
              alt={`月齢${todayMoon.age.toFixed(1)}日`}
              className="w-16 h-16 mx-auto"
            />
            <p className="text-sm text-muted-foreground mt-1">
              月齢 {todayMoon.age.toFixed(1)}日
            </p>
          </div>
          <div>
            <p className="font-medium">
              今日: {format(new Date(), 'yyyy年M月d日', { locale: ja })}
            </p>
            <p className="text-sm text-muted-foreground">
              旧暦: {today.lunar.year}年{today.lunar.monthName}
              {today.lunar.isLeapMonth && '(閏)'}
              {today.lunar.dayName}
            </p>
            <p className="text-sm text-muted-foreground">
              {today.lunar.zodiac}年 {today.lunar.ganzhiYear}
            </p>
          </div>
        </div>
      </div>

      <div className="border rounded-lg overflow-hidden">
        <div className="grid grid-cols-7">
          {weekDays.map((day, i) => (
            <div
              key={day}
              className={`p-2 text-center text-sm font-medium border-b ${
                i === 0 ? 'text-red-500' : i === 6 ? 'text-blue-500' : ''
              }`}
            >
              {day}
            </div>
          ))}
        </div>
        <div className="grid grid-cols-7">
          {emptyDays.map((_, i) => (
            <div key={`empty-${i}`} className="p-2 border-b border-r min-h-[80px]" />
          ))}
          {days.map((day) => {
            const lunar = LunarConverter.gregorianToLunar(
              day.getFullYear(),
              day.getMonth() + 1,
              day.getDate()
            );
            const moon = MoonPhaseCalculator.calculate(day);
            const dayOfWeek = getDay(day);
            const isToday =
              format(day, 'yyyy-MM-dd') === format(new Date(), 'yyyy-MM-dd');

            return (
              <div
                key={day.toISOString()}
                className={`p-2 border-b border-r min-h-[80px] ${
                  isToday ? 'bg-blue-50' : ''
                }`}
              >
                <div className="flex justify-between items-start">
                  <span
                    className={`text-sm font-medium ${
                      dayOfWeek === 0
                        ? 'text-red-500'
                        : dayOfWeek === 6
                        ? 'text-blue-500'
                        : ''
                    }`}
                  >
                    {calendarType === 'GREGORIAN'
                      ? day.getDate()
                      : lunar.lunar.day}
                  </span>
                  <img
                    src={moon.imagePath}
                    alt={`月齢${moon.age.toFixed(1)}`}
                    className="w-4 h-4"
                  />
                </div>
                <p className="text-xs text-muted-foreground mt-1">
                  {calendarType === 'GREGORIAN'
                    ? `${lunar.lunar.monthName}${lunar.lunar.dayName}`
                    : `${lunar.gregorian.month}/${lunar.gregorian.day}`}
                </p>
                {lunar.lunar.solarTerm && (
                  <p className="text-xs text-green-600 mt-1">
                    {lunar.lunar.solarTerm}
                  </p>
                )}
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}

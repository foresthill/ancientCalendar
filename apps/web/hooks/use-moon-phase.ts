import { useMemo } from 'react';
import { MoonPhaseCalculator, MoonPhase } from '@repo/calendar-core';

export function useMoonPhase(date: Date): MoonPhase {
  return useMemo(() => {
    return MoonPhaseCalculator.calculate(date);
  }, [date]);
}

export function useTodayMoonPhase(): MoonPhase {
  return useMemo(() => {
    return MoonPhaseCalculator.today();
  }, []);
}

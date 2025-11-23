import { create } from 'zustand';

type CalendarType = 'GREGORIAN' | 'LUNAR';

interface CalendarState {
  currentDate: Date;
  calendarType: CalendarType;
  selectedDate: Date | null;
  setCurrentDate: (date: Date) => void;
  setCalendarType: (type: CalendarType) => void;
  setSelectedDate: (date: Date | null) => void;
  toggleCalendarType: () => void;
  nextMonth: () => void;
  prevMonth: () => void;
}

export const useCalendarStore = create<CalendarState>((set) => ({
  currentDate: new Date(),
  calendarType: 'GREGORIAN',
  selectedDate: null,

  setCurrentDate: (date) => set({ currentDate: date }),
  setCalendarType: (type) => set({ calendarType: type }),
  setSelectedDate: (date) => set({ selectedDate: date }),

  toggleCalendarType: () =>
    set((state) => ({
      calendarType: state.calendarType === 'GREGORIAN' ? 'LUNAR' : 'GREGORIAN'
    })),

  nextMonth: () =>
    set((state) => ({
      currentDate: new Date(
        state.currentDate.getFullYear(),
        state.currentDate.getMonth() + 1,
        1
      )
    })),

  prevMonth: () =>
    set((state) => ({
      currentDate: new Date(
        state.currentDate.getFullYear(),
        state.currentDate.getMonth() - 1,
        1
      )
    }))
}));

export type CalendarType = 'GREGORIAN' | 'LUNAR';

export interface Event {
  id: string;
  title: string;
  description?: string;
  location?: string;
  startDate: Date;
  endDate?: Date;
  allDay: boolean;
  timezone: string;
  calendarType: CalendarType;
  lunarYear?: number;
  lunarMonth?: number;
  lunarDay?: number;
  isLeapMonth: boolean;
  category?: string;
  tags: string[];
  color?: string;
  moonPhase?: string;
  userId: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface CalendarViewState {
  year: number;
  month: number;
  calendarType: CalendarType;
  selectedDate?: Date;
}

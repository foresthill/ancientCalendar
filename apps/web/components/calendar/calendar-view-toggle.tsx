'use client';

import { Button } from '@/components/ui/button';
import { motion } from 'framer-motion';

interface CalendarViewToggleProps {
  view: 'gregorian' | 'lunar';
  onChange: (view: 'gregorian' | 'lunar') => void;
}

export function CalendarViewToggle({ view, onChange }: CalendarViewToggleProps) {
  return (
    <div className="inline-flex rounded-lg border p-1 bg-muted">
      <Button
        variant={view === 'gregorian' ? 'default' : 'ghost'}
        size="sm"
        onClick={() => onChange('gregorian')}
        className="relative"
      >
        {view === 'gregorian' && (
          <motion.div
            layoutId="activeTab"
            className="absolute inset-0 bg-primary rounded-md"
            transition={{ type: 'spring', duration: 0.5 }}
          />
        )}
        <span className="relative z-10">新暦</span>
      </Button>

      <Button
        variant={view === 'lunar' ? 'default' : 'ghost'}
        size="sm"
        onClick={() => onChange('lunar')}
        className="relative"
      >
        {view === 'lunar' && (
          <motion.div
            layoutId="activeTab"
            className="absolute inset-0 bg-primary rounded-md"
            transition={{ type: 'spring', duration: 0.5 }}
          />
        )}
        <span className="relative z-10">旧暦</span>
      </Button>
    </div>
  );
}

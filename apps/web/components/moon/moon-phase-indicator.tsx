'use client';

import Image from 'next/image';
import { MoonPhaseCalculator } from '@repo/calendar-core';

interface MoonPhaseIndicatorProps {
  date: Date;
  size?: 'sm' | 'md' | 'lg';
  showAge?: boolean;
  className?: string;
}

export function MoonPhaseIndicator({
  date,
  size = 'md',
  showAge = false,
  className = ''
}: MoonPhaseIndicatorProps) {
  const moonPhase = MoonPhaseCalculator.calculate(date);

  const sizeMap = {
    sm: 32,
    md: 64,
    lg: 128
  };

  const imageSize = sizeMap[size];

  return (
    <div className={`flex flex-col items-center gap-1 ${className}`}>
      <div className="relative" style={{ width: imageSize, height: imageSize }}>
        <Image
          src={moonPhase.imagePath}
          alt={`月齢${moonPhase.age.toFixed(1)}日`}
          fill
          className="object-contain"
          sizes={`${imageSize}px`}
        />
      </div>
      {showAge && (
        <span className="text-xs text-muted-foreground">
          月齢 {moonPhase.age.toFixed(1)}日
        </span>
      )}
      <span className="sr-only">
        {moonPhase.phase} - 月齢 {moonPhase.age.toFixed(1)}日 - 照度{' '}
        {moonPhase.illumination.toFixed(0)}%
      </span>
    </div>
  );
}

import Foundation

// This is a standalone test script for the calendar conversion issue
// You can run it directly with `swift TestConversion.swift`

// Create a CalendarManager instance
let calendarManager = CalendarManager.sharedInstance

// Step 1: Set up the date we want to test (2025-07-02)
calendarManager.year = 2025
calendarManager.month = 7
calendarManager.day = 2
calendarManager.calendarMode = 1 // Gregorian mode
calendarManager.nowLeapMonth = false
calendarManager.isLeapMonth = 0

print("Initial setup: \(calendarManager.year ?? 0)年\(calendarManager.month ?? 0)月\(calendarManager.day ?? 0)日 (新暦)")

// Step 2: Initialize the schedule view and perform the conversion
calendarManager.initScheduleViewController()

print("After initScheduleViewController:")
print("旧暦: \(calendarManager.ancientYear ?? 0)年\(calendarManager.nowLeapMonth ? "閏" : "")\(calendarManager.ancientMonth ?? 0)月\(calendarManager.ancientDay ?? 0)日 [isLeapMonth=\(calendarManager.isLeapMonth ?? 0)]")

// Step 3: Switch to the ancient calendar mode
calendarManager.calendarMode = -1
calendarManager.setupAnotherCalendarData()

print("After switching to ancient calendar mode:")
print("\(calendarManager.year ?? 0)年\(calendarManager.nowLeapMonth ? "閏" : "")\(calendarManager.month ?? 0)月\(calendarManager.day ?? 0)日 [isLeapMonth=\(calendarManager.isLeapMonth ?? 0)]")

// Step 4: Verify that we have the correct result (should be regular 6/8, not leap 6/8)
if calendarManager.month == 6 && calendarManager.day == 8 && !calendarManager.nowLeapMonth {
    print("✅ TEST PASSED: The date is correctly showing as regular 6/8")
} else {
    print("❌ TEST FAILED: Expected regular 6/8, but got \(calendarManager.nowLeapMonth ? "閏" : "")\(calendarManager.month ?? 0)月\(calendarManager.day ?? 0)日")
}
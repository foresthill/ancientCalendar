import Foundation

func testAncientCalendarLeapMonthTransition() {
    // Create a CalendarConverter instance
    class CalendarConverter {
        // Copied from the original class
        let o2ntbl = [[611,2350],[468,3222],[316,7317],[559,3402],[416,3493],
            [288,2901],[520,1388],[384,5467],[637,605],[494,2349],[343,6443],
            [585,2709],[442,2890],[302,5962],[533,2901],[412,2741],[650,1210],
            [507,2651],[369,2647],[611,1323],[468,2709],[329,5781],[559,1706],
            [416,2773],[288,2741],[533,1206],[383,5294],[624,2647],[494,1319],
            [356,3366],[572,3475],[442,1450]]
        
        let minYear = 1999
        let maxYear = 2030
        
        var ancientTbl: [[Int]] = Array(repeating: [0, 0], count: 14)
        var leapMonth: Int!
        var isLeapMonth: Int!
        var ommax: Int! = 12
        
        func isLeapYear(inYear: Int) -> Int {
            var isLeap = 0
            if(inYear % 400 == 0 || (inYear % 4 == 0 && inYear % 100 != 0)) {
                isLeap = 1
            }
            return isLeap
        }
        
        func tblExpand(_ inYear: Int) {
            var days: Double = Double(o2ntbl[inYear - minYear][0])
            var bits: Int = o2ntbl[inYear - minYear][1]
            leapMonth = Int(days) % 13
            
            days = floor((Double(days) / 13.0) + 0.001)
            
            ancientTbl[0] = [Int(days), 1]
            
            if(leapMonth == 0) {
                bits *= 2
                ommax = 12
            } else {
                ommax = 13
            }
            
            for i in 1...ommax {
                ancientTbl[i] = [ancientTbl[i-1][0]+29, i+1]
                if(bits >= 4096) {
                    ancientTbl[i][0] += 1
                }
                bits = (bits % 4096) * 2
            }
            ancientTbl[ommax][1] = 0
            
            if (ommax > 12) {
                for i in leapMonth+1...12 {
                    ancientTbl[i][1] = i
                }
                ancientTbl[leapMonth][1] = -leapMonth
            } else {
                ancientTbl[13] = [0, 0]
            }
        }
        
        // Function to convert a Gregorian date to the corresponding ancient calendar date
        func convertToAncient(year: Int, month: Int, day: Int) -> (year: Int, month: Int, day: Int, isLeap: Bool) {
            tblExpand(year)
            
            // Create a date object
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = day
            
            let calendar = Calendar(identifier: .gregorian)
            guard let date = calendar.date(from: components) else {
                return (year, 1, 1, false) // Default return on error
            }
            
            let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date)!
            
            // If date is before ancient new year, it's in previous ancient year
            if dayOfYear < ancientTbl[0][0] {
                return (year - 1, 1, 1, false) // Simplified - would need to recalculate for previous year
            }
            
            // Find the corresponding ancient month and day
            var ancientMonth = 1
            var ancientDay = 1
            var isLeap = false
            
            for i in (0...ommax).reversed() {
                if ancientTbl[i][1] != 0 && ancientTbl[i][0] <= dayOfYear {
                    let monthVal = ancientTbl[i][1]
                    ancientMonth = abs(monthVal)
                    isLeap = monthVal < 0
                    ancientDay = dayOfYear - ancientTbl[i][0] + 1
                    break
                }
            }
            
            return (year, ancientMonth, ancientDay, isLeap)
        }
        
        // Function to convert an ancient date to its Gregorian equivalent
        func convertToGregorian(year: Int, month: Int, day: Int, isLeap: Bool) -> (year: Int, month: Int, day: Int)? {
            tblExpand(year)
            
            // Validate if this is a valid ancient date
            if month < 1 || month > 12 || day < 1 {
                return nil
            }
            
            // If isLeap is true but this month is not the leap month, it's invalid
            if isLeap && leapMonth != month {
                return nil
            }
            
            // Find the day of year for this ancient date
            var dayOfYear = 0
            var targetMonth = month
            if isLeap {
                targetMonth = -month
            }
            
            var monthFound = false
            for i in 0...ommax {
                if ancientTbl[i][1] == targetMonth {
                    dayOfYear = ancientTbl[i][0] + day - 1
                    monthFound = true
                    break
                }
            }
            
            if !monthFound {
                return nil
            }
            
            // Convert day of year to Gregorian date
            var dateComponents = DateComponents()
            dateComponents.year = year
            dateComponents.day = dayOfYear
            
            let calendar = Calendar(identifier: .gregorian)
            guard let date = calendar.date(from: dateComponents) else {
                return nil
            }
            
            let gregorianComponents = calendar.dateComponents([.year, .month, .day], from: date)
            return (gregorianComponents.year!, gregorianComponents.month!, gregorianComponents.day!)
        }
    }
    
    let converter = CalendarConverter()
    let targetYear = 2025
    
    // Generate the ancientTbl for 2025
    converter.tblExpand(targetYear)
    
    // Check the problematic transitions (around Month 6 and Leap Month 6)
    
    print("2025 Ancient Calendar Table:")
    for i in 0..<14 {
        let monthDisplay = converter.ancientTbl[i][1]
        var monthText = "Month \(abs(monthDisplay))"
        if monthDisplay < 0 {
            monthText += " (Leap)"
        }
        print("\(i): [\(converter.ancientTbl[i][0]), \(converter.ancientTbl[i][1])] - Day of Year: \(converter.ancientTbl[i][0]), \(monthText)")
    }
    
    print("\n=== Testing Month 6 to Leap Month 6 Transition ===")
    
    // Convert June 26 (non-leap) to Gregorian and back
    if let june26Gregorian = converter.convertToGregorian(year: 2025, month: 6, day: 1, isLeap: false) {
        print("\nMonth 6, Day 1 → Gregorian: \(june26Gregorian.year)/\(june26Gregorian.month)/\(june26Gregorian.day)")
        
        // Convert back to ancient
        let june26ToAncient = converter.convertToAncient(
            year: june26Gregorian.year, 
            month: june26Gregorian.month, 
            day: june26Gregorian.day
        )
        print("Converting back: Gregorian \(june26Gregorian.year)/\(june26Gregorian.month)/\(june26Gregorian.day) → Ancient: Month \(june26ToAncient.month), Day \(june26ToAncient.day) \(june26ToAncient.isLeap ? "(Leap)" : "")")
    }
    
    // Going forward one day from Month 6, Day 30 to Leap Month 6, Day 1
    if let month6Day30 = converter.convertToGregorian(year: 2025, month: 6, day: 30, isLeap: false),
       let leapMonth6Day1 = converter.convertToGregorian(year: 2025, month: 6, day: 1, isLeap: true) {
        
        print("\nMonth 6, Day 30 → Gregorian: \(month6Day30.year)/\(month6Day30.month)/\(month6Day30.day)")
        print("Leap Month 6, Day 1 → Gregorian: \(leapMonth6Day1.year)/\(leapMonth6Day1.month)/\(leapMonth6Day1.day)")
        
        // Test by adding one day to Month 6, Day 30's Gregorian date
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = month6Day30.year
        components.month = month6Day30.month
        components.day = month6Day30.day
        
        if let date = calendar.date(from: components),
           let nextDay = calendar.date(byAdding: .day, value: 1, to: date) {
            let nextDayComp = calendar.dateComponents([.year, .month, .day], from: nextDay)
            print("Next day after \(month6Day30.year)/\(month6Day30.month)/\(month6Day30.day) is \(nextDayComp.year!)/\(nextDayComp.month!)/\(nextDayComp.day!)")
            
            // Check whether this corresponds to Leap Month 6, Day 1
            let backToAncient = converter.convertToAncient(
                year: nextDayComp.year!, 
                month: nextDayComp.month!, 
                day: nextDayComp.day!
            )
            print("This converts to: Month \(backToAncient.month), Day \(backToAncient.day) \(backToAncient.isLeap ? "(Leap)" : "")")
        }
    }
    
    print("\n=== Testing Leap Month 6, Day 1 to Month 6, Day 26 Transition ===")
    
    // Test going from Leap Month 6, Day 1 to Month 6, Day 26
    if let leapMonth6Day1 = converter.convertToGregorian(year: 2025, month: 6, day: 1, isLeap: true),
       let month6Day26 = converter.convertToGregorian(year: 2025, month: 6, day: 26, isLeap: false) {
        
        print("\nLeap Month 6, Day 1 → Gregorian: \(leapMonth6Day1.year)/\(leapMonth6Day1.month)/\(leapMonth6Day1.day)")
        print("Month 6, Day 26 → Gregorian: \(month6Day26.year)/\(month6Day26.month)/\(month6Day26.day)")
        
        // Check if Leap Month 6 Day 1 is after Month 6 Day 26
        let calendar = Calendar.current
        var leapComponents = DateComponents()
        leapComponents.year = leapMonth6Day1.year
        leapComponents.month = leapMonth6Day1.month
        leapComponents.day = leapMonth6Day1.day
        
        var normalComponents = DateComponents()
        normalComponents.year = month6Day26.year
        normalComponents.month = month6Day26.month
        normalComponents.day = month6Day26.day
        
        if let leapDate = calendar.date(from: leapComponents),
           let normalDate = calendar.date(from: normalComponents) {
            let daysDifference = calendar.dateComponents([.day], from: normalDate, to: leapDate).day!
            print("Days between Month 6, Day 26 and Leap Month 6, Day 1: \(daysDifference)")
        }
    }
    
    // Test Leap Month 6, Day 9 to Month 6, Day 8 (going backwards)
    print("\n=== Testing Leap Month 6, Day 9 to Month 6, Day 8 Transition ===")
    
    if let leapMonth6Day9 = converter.convertToGregorian(year: 2025, month: 6, day: 9, isLeap: true),
       let month6Day8 = converter.convertToGregorian(year: 2025, month: 6, day: 8, isLeap: false) {
        
        print("\nLeap Month 6, Day 9 → Gregorian: \(leapMonth6Day9.year)/\(leapMonth6Day9.month)/\(leapMonth6Day9.day)")
        print("Month 6, Day 8 → Gregorian: \(month6Day8.year)/\(month6Day8.month)/\(month6Day8.day)")
        
        // Check if one day before Leap Month 6 Day 9 is Month 6 Day 8
        let calendar = Calendar.current
        var leapComponents = DateComponents()
        leapComponents.year = leapMonth6Day9.year
        leapComponents.month = leapMonth6Day9.month
        leapComponents.day = leapMonth6Day9.day
        
        if let leapDate = calendar.date(from: leapComponents),
           let previousDay = calendar.date(byAdding: .day, value: -1, to: leapDate) {
            let prevDayComp = calendar.dateComponents([.year, .month, .day], from: previousDay)
            print("Previous day before \(leapMonth6Day9.year)/\(leapMonth6Day9.month)/\(leapMonth6Day9.day) is \(prevDayComp.year!)/\(prevDayComp.month!)/\(prevDayComp.day!)")
            
            // Check whether this corresponds to Month 6, Day 8
            let backToAncient = converter.convertToAncient(
                year: prevDayComp.year!, 
                month: prevDayComp.month!, 
                day: prevDayComp.day!
            )
            print("This converts to: Month \(backToAncient.month), Day \(backToAncient.day) \(backToAncient.isLeap ? "(Leap)" : "")")
            
            // Compare with direct calculation
            if prevDayComp.year! == month6Day8.year && 
               prevDayComp.month! == month6Day8.month && 
               prevDayComp.day! == month6Day8.day {
                print("Confirmed: The day before Leap Month 6, Day 9 is Month 6, Day 8")
            } else {
                print("Discrepancy: The day before Leap Month 6, Day 9 is \(prevDayComp.year!)/\(prevDayComp.month!)/\(prevDayComp.day!), but Month 6, Day 8 is \(month6Day8.year)/\(month6Day8.month)/\(month6Day8.day)")
            }
        }
    }
}

testAncientCalendarLeapMonthTransition()
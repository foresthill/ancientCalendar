import Foundation

func testAncientCalendarReverseConversion() {
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
        
        // Simple implementation to find day of year for ancient dates
        func findDayOfYear(year: Int, month: Int, day: Int, isLeap: Bool) -> Int? {
            tblExpand(year)
            
            // Find the starting day for this month in the table
            var startDay = 0
            var targetMonth = month
            if isLeap {
                targetMonth = -month
            }
            
            for i in 0...ommax {
                if ancientTbl[i][1] == targetMonth {
                    startDay = ancientTbl[i][0]
                    return startDay + day - 1
                }
            }
            
            return nil
        }
    }
    
    let converter = CalendarConverter()
    let targetYear = 2025
    
    // Generate the ancientTbl for 2025
    converter.tblExpand(targetYear)
    
    // Print the ancientTbl content for 2025
    print("Year 2025 Ancient Calendar Table:")
    for i in 0..<14 {
        let monthDisplay = converter.ancientTbl[i][1]
        var monthText = "Month \(abs(monthDisplay))"
        if monthDisplay < 0 {
            monthText += " (Leap)"
        }
        print("\(i): [\(converter.ancientTbl[i][0]), \(converter.ancientTbl[i][1])] - Day of Year: \(converter.ancientTbl[i][0]), \(monthText)")
    }
    
    // Test specific transitions around the problem areas
    print("\nTesting transitions around 6/26-6/27:")
    
    let calendar = Calendar(identifier: .gregorian)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    // Function to convert day of year to Gregorian date
    func dayOfYearToDate(year: Int, dayOfYear: Int) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.day = dayOfYear
        return calendar.date(from: dateComponents)
    }
    
    func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Invalid date" }
        return dateFormatter.string(from: date)
    }
    
    // Check the transition between 6/26 and 6/27
    print("\nMonth 6 to Leap Month 6 transition:")
    for i in 0...6 {
        let dayIndex = 5 + i
        let normalMonth6Day = converter.findDayOfYear(year: 2025, month: 6, day: i+1, isLeap: false)
        let leapMonth6Day = converter.findDayOfYear(year: 2025, month: 6, day: i+1, isLeap: true)
        
        if let normalDay = normalMonth6Day {
            let date = dayOfYearToDate(year: 2025, dayOfYear: normalDay)
            print("Month 6, Day \(i+1) → Day of Year: \(normalDay) → Gregorian: \(formatDate(date))")
        }
        
        if let leapDay = leapMonth6Day {
            let date = dayOfYearToDate(year: 2025, dayOfYear: leapDay)
            print("Leap Month 6, Day \(i+1) → Day of Year: \(leapDay) → Gregorian: \(formatDate(date))")
        }
    }
    
    // Check the transition between regular month 5 and 6
    print("\nMonth 5 to Month 6 transition:")
    for i in 26...31 {
        let month5Day = converter.findDayOfYear(year: 2025, month: 5, day: i, isLeap: false)
        
        if let day = month5Day {
            let date = dayOfYearToDate(year: 2025, dayOfYear: day)
            print("Month 5, Day \(i) → Day of Year: \(day) → Gregorian: \(formatDate(date))")
        }
    }
    
    for i in 1...5 {
        let month6Day = converter.findDayOfYear(year: 2025, month: 6, day: i, isLeap: false)
        
        if let day = month6Day {
            let date = dayOfYearToDate(year: 2025, dayOfYear: day)
            print("Month 6, Day \(i) → Day of Year: \(day) → Gregorian: \(formatDate(date))")
        }
    }
}

testAncientCalendarReverseConversion()
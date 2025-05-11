import Foundation

func testAncientCalendarConversion() {
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
    }
    
    let converter = CalendarConverter()
    let targetYear = 2025
    
    // Generate the ancientTbl for 2025
    converter.tblExpand(targetYear)
    
    // Print the leapMonth and ancientTbl content for 2025
    print("Year 2025:")
    print("Leap Month: \(converter.leapMonth ?? 0)")
    print("Month Count (ommax): \(converter.ommax ?? 0)")
    print("Ancient Table:")
    
    for i in 0..<14 {
        let monthDisplay = converter.ancientTbl[i][1]
        var monthText = "Month \(abs(monthDisplay))"
        if monthDisplay < 0 {
            monthText += " (Leap)"
        }
        print("\(i): [\(converter.ancientTbl[i][0]), \(converter.ancientTbl[i][1])] - Day of Year: \(converter.ancientTbl[i][0]), \(monthText)")
    }
    
    // Create a formatter to display dates
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    // Test specific dates in June 2025
    print("\nTesting specific dates in June 2025:")
    let juneDates = [(25, "6/25"), (26, "6/26"), (27, "6/27"), (28, "6/28")]
    let earlyJuneDates = [(7, "6/7"), (8, "6/8"), (9, "6/9"), (10, "6/10")]
    
    func getDateComponents(year: Int, month: Int, day: Int) -> DateComponents {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return components
    }
    
    func displayDate(day: Int, label: String) {
        let components = getDateComponents(year: 2025, month: 6, day: day)
        let date = Calendar.current.date(from: components)!
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date)!
        
        // Find the corresponding ancient month and day
        var ancientMonth = 0
        var ancientDay = 0
        var isLeap = false
        
        for i in (0...12).reversed() {
            if converter.ancientTbl[i][1] != 0 && converter.ancientTbl[i][0] <= dayOfYear {
                let monthVal = converter.ancientTbl[i][1]
                ancientMonth = abs(monthVal)
                isLeap = monthVal < 0
                ancientDay = dayOfYear - converter.ancientTbl[i][0] + 1
                break
            }
        }
        
        print("\(label) (Day of Year: \(dayOfYear)) corresponds to \(isLeap ? "Leap " : "")Month \(ancientMonth), Day \(ancientDay)")
    }
    
    print("\nLate June transition:")
    for (day, label) in juneDates {
        displayDate(day: day, label: label)
    }
    
    print("\nEarly June transition:")
    for (day, label) in earlyJuneDates {
        displayDate(day: day, label: label)
    }
}

testAncientCalendarConversion()

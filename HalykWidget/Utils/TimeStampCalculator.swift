//
//  TimeStampCalculator.swift
//  HalykWidget
//
//  Created by Zhanibek Lukpanov on 26.09.2024.
//

import Foundation

struct TimeStampCalculator {

    private static func dateFromString(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: dateString)
    }

    static func callculate(from dateString: String) -> UInt64 {
        guard let date = dateFromString(dateString) else { return .zero }

        let timestampInSeconds = date.timeIntervalSince1970
        let timestampInNanoseconds = UInt64(timestampInSeconds * 1_000_000_000)
        let fiveMinutesInNanoseconds: UInt64 = 300 * 1_000_000_000

        return timestampInNanoseconds + fiveMinutesInNanoseconds
    }
}

//
//  PhoneNumber.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 26/09/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

/**
 Parsed phone number object

 - numberString: String used to generate phone number struct
 - countryCode: Country dialing code as an unsigned. Int.
 - leadingZero: Some countries (e.g. Italy) require leading zeros. Bool.
 - nationalNumber: National number as an unsigned. Int.
 - numberExtension: Extension if available. String. Optional
 - type: Computed phone number type on access. Returns from an enumeration - PNPhoneNumberType.
 */
struct PhoneNumberKit_PhoneNumber: Codable {
    let numberString: String
    let countryCode: UInt64
    let leadingZero: Bool
    let nationalNumber: UInt64
    let numberExtension: String?
    let type: PhoneNumberKit_PhoneNumberType
    let regionID: String?
}

extension PhoneNumberKit_PhoneNumber: Equatable {
    static func == (lhs: PhoneNumberKit_PhoneNumber, rhs: PhoneNumberKit_PhoneNumber) -> Bool {
        return (lhs.countryCode == rhs.countryCode)
            && (lhs.leadingZero == rhs.leadingZero)
            && (lhs.nationalNumber == rhs.nationalNumber)
            && (lhs.numberExtension == rhs.numberExtension)
    }
}

extension PhoneNumberKit_PhoneNumber: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.countryCode)
        hasher.combine(self.nationalNumber)
        hasher.combine(self.leadingZero)
        if let numberExtension = numberExtension {
            hasher.combine(numberExtension)
        } else {
            hasher.combine(0)
        }
    }
}

extension PhoneNumberKit_PhoneNumber {
    static func notPhoneNumber() -> PhoneNumberKit_PhoneNumber {
        return PhoneNumberKit_PhoneNumber(numberString: "", countryCode: 0, leadingZero: false, nationalNumber: 0, numberExtension: nil, type: .notParsed, regionID: nil)
    }

    func notParsed() -> Bool {
        return self.type == .notParsed
    }
}

/// In past versions of PhoneNumberKit you were able to initialize a PhoneNumber object to parse a String. Please use a PhoneNumberKit object's methods.
extension PhoneNumberKit_PhoneNumber {
    /**
     DEPRECATED.
     Parse a string into a phone number object using default region. Can throw.
     - Parameter rawNumber: String to be parsed to phone number struct.
     */
    @available(*, unavailable, message: "use PhoneNumberKit instead to produce PhoneNumbers")
    init(rawNumber: String) throws {
        assertionFailure(PhoneNumberKit_PhoneNumberError.deprecated.localizedDescription)
        throw PhoneNumberKit_PhoneNumberError.deprecated
    }

    /**
     DEPRECATED.
     Parse a string into a phone number object using custom region. Can throw.
     - Parameter rawNumber: String to be parsed to phone number struct.
     - Parameter region: ISO 639 compliant region code.
     */
    @available(*, unavailable, message: "use PhoneNumberKit instead to produce PhoneNumbers")
    init(rawNumber: String, region: String) throws {
        throw PhoneNumberKit_PhoneNumberError.deprecated
    }
}

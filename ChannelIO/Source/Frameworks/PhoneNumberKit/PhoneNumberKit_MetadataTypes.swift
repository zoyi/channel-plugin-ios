//
//  MetadataTypes.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 02/11/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

/**
 MetadataTerritory object
 - Parameter codeID: ISO 639 compliant region code
 - Parameter countryCode: International country code
 - Parameter internationalPrefix: International prefix. Optional.
 - Parameter mainCountryForCode: Whether the current metadata is the main country for its country code.
 - Parameter nationalPrefix: National prefix
 - Parameter nationalPrefixFormattingRule: National prefix formatting rule
 - Parameter nationalPrefixForParsing: National prefix for parsing
 - Parameter nationalPrefixTransformRule: National prefix transform rule
 - Parameter emergency: MetadataPhoneNumberDesc for emergency numbers
 - Parameter fixedLine: MetadataPhoneNumberDesc for fixed line numbers
 - Parameter generalDesc: MetadataPhoneNumberDesc for general numbers
 - Parameter mobile: MetadataPhoneNumberDesc for mobile numbers
 - Parameter pager: MetadataPhoneNumberDesc for pager numbers
 - Parameter personalNumber: MetadataPhoneNumberDesc for personal number numbers
 - Parameter premiumRate: MetadataPhoneNumberDesc for premium rate numbers
 - Parameter sharedCost: MetadataPhoneNumberDesc for shared cost numbers
 - Parameter tollFree: MetadataPhoneNumberDesc for toll free numbers
 - Parameter voicemail: MetadataPhoneNumberDesc for voice mail numbers
 - Parameter voip: MetadataPhoneNumberDesc for voip numbers
 - Parameter uan: MetadataPhoneNumberDesc for uan numbers
 - Parameter leadingDigits: Optional leading digits for the territory
 */
struct PhoneNumberKit_MetadataTerritory: Decodable {
    let codeID: String
    let countryCode: UInt64
    let internationalPrefix: String?
    let mainCountryForCode: Bool
    let nationalPrefix: String?
    let nationalPrefixFormattingRule: String?
    let nationalPrefixForParsing: String?
    let nationalPrefixTransformRule: String?
    let preferredExtnPrefix: String?
    let emergency: PhoneNumberKit_MetadataPhoneNumberDesc?
    let fixedLine: PhoneNumberKit_MetadataPhoneNumberDesc?
    let generalDesc: PhoneNumberKit_MetadataPhoneNumberDesc?
    let mobile: PhoneNumberKit_MetadataPhoneNumberDesc?
    let pager: PhoneNumberKit_MetadataPhoneNumberDesc?
    let personalNumber: PhoneNumberKit_MetadataPhoneNumberDesc?
    let premiumRate: PhoneNumberKit_MetadataPhoneNumberDesc?
    let sharedCost: PhoneNumberKit_MetadataPhoneNumberDesc?
    let tollFree: PhoneNumberKit_MetadataPhoneNumberDesc?
    let voicemail: PhoneNumberKit_MetadataPhoneNumberDesc?
    let voip: PhoneNumberKit_MetadataPhoneNumberDesc?
    let uan: PhoneNumberKit_MetadataPhoneNumberDesc?
    let numberFormats: [PhoneNumberKit_MetadataPhoneNumberFormat]
    let leadingDigits: String?
}

/**
 MetadataPhoneNumberDesc object
 - Parameter exampleNumber: An example phone number for the given type. Optional.
 - Parameter nationalNumberPattern:  National number regex pattern. Optional.
 - Parameter possibleNumberPattern:  Possible number regex pattern. Optional.
 - Parameter possibleLengths: Possible phone number lengths. Optional.
 */
struct PhoneNumberKit_MetadataPhoneNumberDesc: Decodable {
    let exampleNumber: String?
    let nationalNumberPattern: String?
    let possibleNumberPattern: String?
    let possibleLengths: PhoneNumberKit_MetadataPossibleLengths?
}

struct PhoneNumberKit_MetadataPossibleLengths: Decodable {
    let national: String?
    let localOnly: String?
}

/**
 MetadataPhoneNumberFormat object
 - Parameter pattern: Regex pattern. Optional.
 - Parameter format: Formatting template. Optional.
 - Parameter intlFormat: International formatting template. Optional.

 - Parameter leadingDigitsPatterns: Leading digits regex pattern. Optional.
 - Parameter nationalPrefixFormattingRule: National prefix formatting rule. Optional.
 - Parameter nationalPrefixOptionalWhenFormatting: National prefix optional bool. Optional.
 - Parameter domesticCarrierCodeFormattingRule: Domestic carrier code formatting rule. Optional.
 */
struct PhoneNumberKit_MetadataPhoneNumberFormat: Decodable {
    let pattern: String?
    let format: String?
    let intlFormat: String?
    let leadingDigitsPatterns: [String]?
    var nationalPrefixFormattingRule: String?
    let nationalPrefixOptionalWhenFormatting: Bool?
    let domesticCarrierCodeFormattingRule: String?
}

/// Internal object for metadata parsing
internal struct PhoneNumberKit_PhoneNumberMetadata: Decodable {
    var territories: [PhoneNumberKit_MetadataTerritory]
}

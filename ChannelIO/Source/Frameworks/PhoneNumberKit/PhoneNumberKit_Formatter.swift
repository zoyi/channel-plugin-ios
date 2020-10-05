//
//  Formatter.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 03/11/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

final class PhoneNumberKit_Formatter {
    weak var regexManager: PhoneNumberKit_RegexManager?

    init(phoneNumberKit: PhoneNumberKit) {
        self.regexManager = phoneNumberKit.regexManager
    }

    init(regexManager: PhoneNumberKit_RegexManager) {
        self.regexManager = regexManager
    }

    // MARK: Formatting functions

    /// Formats phone numbers for display
    ///
    /// - Parameters:
    ///   - phoneNumber: Phone number object.
    ///   - formatType: Format type.
    ///   - regionMetadata: Region meta data.
    /// - Returns: Formatted Modified national number ready for display.
    func format(phoneNumber: PhoneNumberKit_PhoneNumber, formatType: PhoneNumberKit_PhoneNumberFormat, regionMetadata: PhoneNumberKit_MetadataTerritory?) -> String {
        var formattedNationalNumber = phoneNumber.adjustedNationalNumber()
        if let regionMetadata = regionMetadata {
            formattedNationalNumber = self.formatNationalNumber(formattedNationalNumber, regionMetadata: regionMetadata, formatType: formatType)
            if let formattedExtension = formatExtension(phoneNumber.numberExtension, regionMetadata: regionMetadata) {
                formattedNationalNumber = formattedNationalNumber + formattedExtension
            }
        }
        return formattedNationalNumber
    }

    /// Formats extension for display
    ///
    /// - Parameters:
    ///   - numberExtension: Number extension string.
    ///   - regionMetadata: Region meta data.
    /// - Returns: Modified number extension with either a preferred extension prefix or the default one.
    func formatExtension(_ numberExtension: String?, regionMetadata: PhoneNumberKit_MetadataTerritory) -> String? {
        if let extns = numberExtension {
            if let preferredExtnPrefix = regionMetadata.preferredExtnPrefix {
                return "\(preferredExtnPrefix)\(extns)"
            } else {
                return "\(PhoneNumberKit_PhoneNumberConstants.defaultExtnPrefix)\(extns)"
            }
        }
        return nil
    }

    /// Formats national number for display
    ///
    /// - Parameters:
    ///   - nationalNumber: National number string.
    ///   - regionMetadata: Region meta data.
    ///   - formatType: Format type.
    /// - Returns: Modified nationalNumber for display.
    func formatNationalNumber(_ nationalNumber: String, regionMetadata: PhoneNumberKit_MetadataTerritory, formatType: PhoneNumberKit_PhoneNumberFormat) -> String {
        guard let regexManager = regexManager else { return nationalNumber }
        let formats = regionMetadata.numberFormats
        var selectedFormat: PhoneNumberKit_MetadataPhoneNumberFormat?
        for format in formats {
            if let leadingDigitPattern = format.leadingDigitsPatterns?.last {
                if regexManager.stringPositionByRegex(leadingDigitPattern, string: String(nationalNumber)) == 0 {
                    if regexManager.matchesEntirely(format.pattern, string: String(nationalNumber)) {
                        selectedFormat = format
                        break
                    }
                }
            } else {
                if regexManager.matchesEntirely(format.pattern, string: String(nationalNumber)) {
                    selectedFormat = format
                    break
                }
            }
        }
        if let formatPattern = selectedFormat {
            guard let numberFormatRule = (formatType == PhoneNumberKit_PhoneNumberFormat.international && formatPattern.intlFormat != nil) ? formatPattern.intlFormat : formatPattern.format, let pattern = formatPattern.pattern else {
                return nationalNumber
            }
            var formattedNationalNumber = String()
            var prefixFormattingRule = String()
            if let nationalPrefixFormattingRule = formatPattern.nationalPrefixFormattingRule, let nationalPrefix = regionMetadata.nationalPrefix {
                prefixFormattingRule = regexManager.replaceStringByRegex(PhoneNumberKit_PhoneNumberPatterns.npPattern, string: nationalPrefixFormattingRule, template: nationalPrefix)
                prefixFormattingRule = regexManager.replaceStringByRegex(PhoneNumberKit_PhoneNumberPatterns.fgPattern, string: prefixFormattingRule, template: "\\$1")
            }
            if formatType == PhoneNumberKit_PhoneNumberFormat.national, regexManager.hasValue(prefixFormattingRule) {
                let replacePattern = regexManager.replaceFirstStringByRegex(PhoneNumberKit_PhoneNumberPatterns.firstGroupPattern, string: numberFormatRule, templateString: prefixFormattingRule)
                formattedNationalNumber = regexManager.replaceStringByRegex(pattern, string: nationalNumber, template: replacePattern)
            } else {
                formattedNationalNumber = regexManager.replaceStringByRegex(pattern, string: nationalNumber, template: numberFormatRule)
            }
            return formattedNationalNumber
        } else {
            return nationalNumber
        }
    }
}

extension PhoneNumberKit_PhoneNumber {
    /**
     Adjust national number for display by adding leading zero if needed. Used for basic formatting functions.
     - Returns: A string representing the adjusted national number.
     */
    func adjustedNationalNumber() -> String {
        if self.leadingZero == true {
            return "0" + String(nationalNumber)
        } else {
            return String(nationalNumber)
        }
    }
}

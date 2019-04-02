//
//  TLAssetCollection+Extension.swift
//  TLPhotoPicker
//
//  Created by wade.hawk on 21/01/2019.
//
//  Copyright (c) 2017 wade.hawk <junhyi.park@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import Photos

enum PHFetchedResultGroupedBy {
    case year
    case month
    case week
    case day
    case hour
    case custom(dateFormat: String)
    var dateFormat: String {
        switch self {
        case .year:
            return "yyyy"
        case .month:
            return "yyyyMM"
        case .week:
            return "yyyyMMW"
        case .day:
            return "yyyyMMdd"
        case .hour:
            return "yyyyMMddHH"
        case let .custom(dateFormat):
            return dateFormat
        }
    }
}

internal extension TLAssetsCollection {
    func enumarateFetchResult(groupedBy: PHFetchedResultGroupedBy) -> Dictionary<String,[TLPHAsset]> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = groupedBy.dateFormat
        var assets = [PHAsset]()
        assets.reserveCapacity(self.fetchResult?.count ?? 0)
        self.fetchResult?.enumerateObjects({ (phAsset, idx, stop) in
            if phAsset.creationDate != nil {
                assets.append(phAsset)
            }
        })
        let sections = Dictionary(grouping: assets.map{ TLPHAsset(asset: $0) }) { (element) -> String in
            if let creationDate = element.phAsset?.creationDate {
                let identifier = dateFormatter.string(from: creationDate)
                return identifier
            }
            return ""
        }
        return sections
    }

    func section(groupedBy: PHFetchedResultGroupedBy) -> [(String,[TLPHAsset])] {
        let dict = enumarateFetchResult(groupedBy: groupedBy)
        var sections = [(String,[TLPHAsset])]()
        let sortedKeys = dict.keys.sorted(by: >)
        for key in sortedKeys {
            if let array = dict[key] {
                sections.append((key, array))
            }
        }
        return sections
    }
}

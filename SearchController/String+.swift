//
//  String+.swift
//  SearchController
//
//  Created by Scott Gardner on 2/6/19.
//  Copyright © 2019 Scott Gardner. All rights reserved.
//

import Foundation

extension String {

    func ranges(of substring: String, options: CompareOptions = [], locale: Locale? = nil) -> [Range<Index>] {
        var ranges = [Range<Index>]()

        while let range = range(of: substring, options: options, range: (ranges.last?.upperBound ?? startIndex)..<endIndex, locale: locale) {
            ranges.append(range)
        }
        
        return ranges
    }
}

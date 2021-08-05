//
//  GeometryUtilities.swift
//  Part Finder
//
//  Created by Justin Oakes on 8/5/21.
//

import CoreGraphics

func intersectionOverUnion(_ firstRect: CGRect, _ secondRect: CGRect) -> CGFloat {
    guard !firstRect.isEmpty, !secondRect.isEmpty else {
        return 0
    }

    let intersection = firstRect.intersection(secondRect)
    return intersection.area / (firstRect.area + secondRect.area - intersection.area)
}

private extension CGRect {

    /// The area of a rectangle
    var area: CGFloat {
        return width * height
    }
}

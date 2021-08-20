//
//  UIImage+Resize.swift
//  MyLocations
//
//  Created by Surfa on 19.08.2021.
//

import UIKit

extension UIImage{
    func resize(withBounds bounds: CGSize) -> UIImage {
        let horizontalRatio = bounds.width / size.width
        let verticalRatio = bounds.height / size.height
        let ratio = min(horizontalRatio, verticalRatio )
        
        let newW = size.width * ratio
        let newH = size.height * ratio
        
        let sizeFill = min(newW,newH)
        let newSize = CGSize(width: sizeFill, height: sizeFill)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        
        draw(in: CGRect.init(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

//
//  FlowLayout.swift
//  Tag Flow Layout
//
//  Created by Pawan kumar on 14/05/19.
//  Copyright © 2019 Pawan Kumar. All rights reserved.
//

import Foundation
import UIKit


/*
class FlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect)!.map { $0.copy() as! UICollectionViewLayoutAttributes }
        guard scrollDirection == .vertical else { return layoutAttributes }
        
        // Filter attributes to compute only cell attributes
        let cellAttributes = layoutAttributes.filter({ $0.representedElementCategory == .cell })
        
        // Group cell attributes by row (cells with same vertical center) and loop on those groups
        for (_, attributes) in Dictionary(grouping: cellAttributes, by: { ($0.center.y / 10).rounded(.up) * 10 }) {
            // Set the initial left inset
            var leftInset = sectionInset.left
            
            // Loop on cells to adjust each cell's origin and prepare leftInset for the next cell
            for attribute in attributes {
                attribute.frame.origin.x = leftInset
                leftInset = attribute.frame.maxX + minimumInteritemSpacing
            }
        }
        
        return layoutAttributes
    }
}
*/

public enum Alignment {
    case justified
    case left
    case center
    case right
}

public class FlowLayout: UICollectionViewFlowLayout {
    
    typealias AlignType = (lastRow: Int, lastMargin: CGFloat)
    
    var align: Alignment = .right
    
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        
        let shifFrame: ((UICollectionViewLayoutAttributes) -> Void) = { [unowned self] layoutAttribute in
            if layoutAttribute.frame.origin.x + layoutAttribute.frame.size.width > collectionView.bounds.size.width {
                layoutAttribute.frame.size.width = collectionView.bounds.size.width - self.sectionInset.left - self.sectionInset.right
            }
        }
        
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        var alignData: [AlignType] = []
        
        attributes.forEach { layoutAttribute in
            switch align {
            case .left, .center, .right:
                if layoutAttribute.frame.origin.y >= maxY {
                    alignData.append((lastRow: layoutAttribute.indexPath.row, lastMargin: leftMargin - minimumInteritemSpacing))
                    leftMargin = sectionInset.left
                }
                
                shifFrame(layoutAttribute)
                
                layoutAttribute.frame.origin.x = leftMargin
                
                leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
                
                maxY = max(layoutAttribute.frame.maxY , maxY)
            case .justified:
                shifFrame(layoutAttribute)
            }
        }
        
        align(attributes: attributes, alignData: alignData, leftMargin: leftMargin - minimumInteritemSpacing)
        
        return attributes
    }
    
    private func align(attributes: [UICollectionViewLayoutAttributes], alignData: [AlignType], leftMargin: CGFloat) {
        guard let collectionView = collectionView else { return }
        
        switch align {
        case .left, .justified:
            break
        case .center:
            attributes.forEach { layoutAttribute in
                if let data = alignData.filter({ $0.lastRow > layoutAttribute.indexPath.row }).first {
                    layoutAttribute.frame.origin.x += ((collectionView.bounds.size.width - data.lastMargin - sectionInset.right) / 2)
                } else {
                    layoutAttribute.frame.origin.x += ((collectionView.bounds.size.width - leftMargin - sectionInset.right) / 2)
                }
            }
        case .right:
            attributes.forEach { layoutAttribute in
                if let data = alignData.filter({ $0.lastRow > layoutAttribute.indexPath.row }).first {
                    layoutAttribute.frame.origin.x += (collectionView.bounds.size.width - data.lastMargin - sectionInset.right)
                } else {
                    layoutAttribute.frame.origin.x += (collectionView.bounds.size.width - leftMargin - sectionInset.right)
                }
            }
        }
    }
}



//
//  LBCollectionViewFlowLayout.swift
//  SeeBeauty
//
//  Created by JLB on 2016/11/7.
//  Copyright © 2016年 LB. All rights reserved.
//

import UIKit

class LBCollectionViewFlowLayout: UICollectionViewFlowLayout {

    var columnCount: Int = 2
    var images: NSMutableArray?
    private var layoutAttributes: NSArray?
    private var columnsHeight: [CGFloat] = [0.0, 0.0]

    override func prepare() {
        super.prepare()

        let contentWidth = self.collectionViewContentSize.width - self.sectionInset.left - self.sectionInset.right
        let itemWidth = (contentWidth - CGFloat(columnCount - 1) * self.minimumInteritemSpacing) / CGFloat(columnCount)

        if nil != self.images {
            self.layoutAttributes = attributes(itemWidth: itemWidth)
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.layoutAttributes as! [UICollectionViewLayoutAttributes]?
    }

    override var collectionViewContentSize: CGSize {
        let maxHeight: CGFloat = longestColumnHeight(columnsHeight: columnsHeight)
        return CGSize(width: SCREEN_WIDTH, height: maxHeight)
    }

    // MARK: - 自定义方法

    func attributes(itemWidth: CGFloat) -> NSArray {

        for i in 0..<columnCount {
            columnsHeight[i] = self.sectionInset.top - self.minimumLineSpacing
        }

        let arrayM = NSMutableArray()
        var item = 0

        for i in 0..<images!.count {
            let image = images?[i] as! LBImage
            let height: CGFloat = equalScale(pixel: image.pixel!, itemWidth: itemWidth)
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            let column = shortestColumn(colHeights:columnsHeight)
            let width = itemWidth
            let x = self.sectionInset.left + (width + self.minimumInteritemSpacing) * CGFloat(column)
            let y = columnsHeight[column] + self.minimumLineSpacing
            attributes.frame = CGRect(x: x, y: y, width: width, height: height)
            arrayM.add(attributes)

            columnsHeight[column] += height + self.minimumLineSpacing
            item += 1
        }
        
        return arrayM.copy() as! NSArray
    }

    // 最短列

    func shortestColumn(colHeights: [CGFloat]) -> Int {
        var temp: CGFloat = CGFloat(MAXFLOAT)
        var column = 0

        for i in 0..<colHeights.count {
            if (colHeights[i] < temp) {
                temp = colHeights[i]
                column = i
            }
        }

        return column
    }

    // 最长列的高度

    func longestColumnHeight(columnsHeight: [CGFloat]) -> CGFloat {
        var temp:CGFloat = 0

        for i in 0..<columnsHeight.count {
            if (columnsHeight[i] > temp) {
                temp = columnsHeight[i]
            }
        }
        
        return temp
    }

    // 等比例缩放

    func equalScale(pixel: String, itemWidth: CGFloat) -> CGFloat {
        let range = pixel.range(of: "*")
        let imgWidth: CGFloat = CGFloat(NSString(string: pixel.substring(to: range!.lowerBound)).floatValue)
        let imgHeight: CGFloat = CGFloat(NSString(string: pixel.substring(from: range!.upperBound)).floatValue)

        return imgHeight * itemWidth / imgWidth
    }

}

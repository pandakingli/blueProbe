//
//  Extension.swift
//  blueProbe
//
//  Created by biubiu on 2018/2/26.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

import Foundation


extension Array {
    func join(go2String: (Iterator.Element) -> String, separator: String) -> String {
        var result = ""
        
        for index in startIndex..<endIndex {
            result.append(contentsOf: go2String(self[index]))
            
            if index == self.index(before: endIndex) {
                continue
            }
            result.append(contentsOf: separator)
        }
        
        return result
    }
}

extension Array where Element: Hashable {
    func genericContain<E: Hashable>(_ ele: E) -> Bool {
        for item in self {
            if item.hashValue == ele.hashValue {
                return true
            }
        }
        return false
    }
}

extension String {
    /// 检查字符串是否包含关键字，忽略大小写
    ///
    /// - Parameter keywords: 关键字列表
    /// - Returns:            只要包含keywords中任意一个关键字就返回true
    func contains(_ keywords: [String]) -> Bool {
        if keywords.isEmpty {
            return true
        }
        
        for keyword in keywords {
            if self.lowercased().contains(keyword.lowercased()) {
                return true
            }
        }
        return false
    }
    
    var isSwift: Bool {
        return hasSuffix(".swift")
    }
}

//
//  SwiftInheritParser.swift
//  blueProbe
//
//  Created by biubiu on 2018/2/26.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

import Foundation
import Curry
import Runes
fileprivate enum Intermediate {
    case proto(BPProtocolNode)
    case cls(BPClassNode)
}

extension Array where Element == Intermediate {
    // 按类型分成两个数组
    func separate() -> ([BPProtocolNode], [BPClassNode]) {
        var protocols = [BPProtocolNode]()
        var classes = [BPClassNode]()
        for item in self {
            if case .proto(let node) = item {
                protocols.append(node)
            } else if case .cls(let node) = item {
                classes.append(node)
            }
        }
        return (protocols, classes)
    }
}

// MARK: - SwiftInheritParser

// 解析Swift的继承关系
class SwiftInheritParser: ParserType {
    var parser: Parser<([BPProtocolNode], [BPClassNode])> {
        // 合并protocol和class的解析结果
        return inheritParser.bluemap { (result) -> ([BPProtocolNode], [BPClassNode]) in
            var (protocols, classes) = result.separate()
            classes = classes.distinct
            
            var set = Set<String>()
            for proto in protocols {
                set.insert(proto.name)
            }
            for cls in classes {
                if let name = cls.superKlass, set.contains(name) {
                    cls.superKlass = nil
                    cls.kprotocols.insert(name, at: 0)
                }
            }
            return (protocols, classes)
        }
    }
}

fileprivate extension SwiftInheritParser {
    var inheritParser: Parser<[Intermediate]> {
        let intermediate
            = curry(Intermediate.proto) ~>* SwiftProtocolParser().protocolParser
                <|> curry(Intermediate.cls) ~>* SwiftClassParser().classParser
        return intermediate.continuous
    }
}

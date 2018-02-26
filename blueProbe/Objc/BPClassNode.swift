//
//  BPClassNode.swift
//  blueProbe
//
//  Created by lining on 2018/2/24.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

import Cocoa

class BPClassNode: Node {
    
    var superKlass: String? = nil
    var klassName: String = ""
    var kprotocols: [String] = []
    
    init(_ name: String, _ superClass: String?, _ protos: [String]) {
        
        if let superClass = superClass, !superClass.isEmpty {
            superKlass = superClass
        }
        
        klassName  = name
        kprotocols = protos
        
    }
}

extension BPClassNode {
    convenience init(clsName: String) {
        self.init(clsName, nil, [])
    }
    
    convenience init() {
        self.init("", nil, [])
    }
}

extension BPClassNode: CustomStringConvertible {
   
    var description: String {
        var desc = "{class: \(klassName)"
        
        if let superCls = superKlass {
            desc.append(contentsOf: ", superClass: \(superCls)")
        }
        
        if kprotocols.count > 0 {
            desc.append(contentsOf: ", protocols: \(kprotocols.joined(separator: ", "))")
        }
        
        desc.append(contentsOf: "}")
        return desc
    }
    
}

// MARK: - Merge

extension BPClassNode {
 
    func merge(_ node: BPClassNode) {
        for proto in node.kprotocols {
            if !kprotocols.contains(proto) {
                kprotocols.append(proto)
            }
        }
        
        if superKlass == nil && node.superKlass != nil {
            superKlass = node.superKlass
        }
    }
}

extension Array where Element == BPClassNode {

    mutating func merge(_ others: [BPClassNode]) {
        let set = Set<BPClassNode>(self)
        
        for node in others {
            if let index = set.index(of: node) {
                set[index].merge(node)
            } else {
                self.append(node)
            }
        }
    }
    
    var distinct: [BPClassNode] {
        guard self.count > 1 else {
            return self
        }
        
        var set = Set<BPClassNode>()
        for node in self {
            if let index = set.index(of: node) {
                set[index].merge(node) // 合并相同的节点
            } else {
                set.insert(node)
            }
        }
        
        return Array(set)
    }
}

// MARK: - Hashable

extension BPClassNode: Hashable {
    static func ==(lhs: BPClassNode, rhs: BPClassNode) -> Bool {
        return lhs.klassName == rhs.klassName
    }
    
    var hashValue: Int {
        return klassName.hashValue
    }
}

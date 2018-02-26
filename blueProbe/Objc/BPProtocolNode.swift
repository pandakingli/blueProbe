//
//  BPProtocolNode.swift
//  blueProbe
//
//  Created by didi on 2018/2/26.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

import Foundation
class BPProtocolNode: Node {
    var name: String = ""
    var supers: [String] = []
}

extension BPProtocolNode {
    convenience init(_ name: String, _ supers: [String]?) {
        self.init()
        self.name = name
        self.supers = supers ?? []
    }
}

extension BPProtocolNode: Hashable {
    
    static func ==(_ left: BPProtocolNode, _ right: BPProtocolNode) -> Bool {
        return left.hashValue == right.hashValue
    }
    
    var hashValue: Int {
        return name.hashValue
    }
}

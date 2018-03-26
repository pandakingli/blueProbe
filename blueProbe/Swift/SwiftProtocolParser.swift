//
//  SwiftProtocolParser.swift
//  blueProbe
//
//  Created by biubiu on 2018/2/26.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

import Foundation
import Runes
import Curry

class SwiftProtocolParser: ParserType {
    var parser: Parser<[BPProtocolNode]> {
        return protocolParser.continuous
    }
}

// MARK: - SwiftProtocolParser

extension SwiftProtocolParser {
    /// 解析一个协议定义
    /**
     protocol_definition = 'protocol' NAME inherit_list?
     */
    var protocolParser: Parser<BPProtocolNode> {
        return curry(BPProtocolNode.init)
            ~>* token(.proto) *> token(.name) ~>- go2String
            *<~ trying(inheritList) <* token(.leftBrace)
    }
    
    /// 解析协议的继承列表
    /**
     inherit_list = ':' NAME (',' NAME)*
     */
    var inheritList: Parser<[String]> {
        return token(.colon) *> token(.name).separateBy(token(.comma)) ~>- go2String
    }
}

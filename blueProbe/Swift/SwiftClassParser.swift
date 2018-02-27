//
//  SwiftClassParser.swift
//  blueProbe
//
//  Created by biubiu on 2018/2/26.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

import Foundation

import Runes
import Curry
// MARK: - SwiftClassParser

class SwiftClassParser: ParserType {
    var parser: Parser<[BPClassNode]> {
        return curry({ $0.distinct }) <^> classParser.continuous
    }
}

// MARK: - class parser

extension SwiftClassParser {
    
    var classParser: Parser<BPClassNode> {
        return classDef <|> extensionDef
    }
    
    /// 解析class和struct的定义
    /**
     class_definition = 'class' NAME generics_type? super_class? ',' protocols?
     */
    var classDef: Parser<BPClassNode> {
        // TODO: 区分struct和class
        return curry(BPClassNode.init)
            <^> (token(.cls) <|> token(.structure)) *> token(.name) <* trying (genericType) => stringify // 类名
            <*> trying (superCls) => stringify // 父类
            <*> trying (token(.comma) *> protocols) => stringify // 协议列表
    }
    
    /// 解析extension定义
    /**
     extension_definition = 'extension' NAME (':' protocols)?
     */
    var extensionDef: Parser<BPClassNode> {
        return curry(BPClassNode.init)
            <^> token(.exten) *> token(.name) => stringify
            <*> pure(nil)
            <*> trying (token(.colon) *> protocols) => stringify
    }
    
    /// 解析泛型
    /**
     generics_type = '<' ANY '>'
     */
    var genericType: Parser<String> {
        return anyTokens(inside: token(.leftAngle), and: token(.rightAngle)) *> pure("")
    }
    
    /// 父类
    /**
     super_class = ':' NAME
     */
    var superCls: Parser<Token> {
        return token(.colon) *> token(.name)
    }
    
    /// 协议列表
    /**
     protocols = NAME (',' NAME)*
     */
    var protocols: Parser<[Token]> {
        return token(.name).separateBy(token(.comma))
    }
}

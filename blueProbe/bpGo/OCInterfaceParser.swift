//
//  OCInterfaceParser.swift
//  blueProbe
//
//  Created by biubiu on 2018/2/26.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

import Foundation
import Curry
import Runes

class OCInterfaceParser: ParserType {
    var parser: Parser<[BPClassNode]> {
        return curry({ $0.distinct }) ~>* (categoryParser <|> classParser).continuous
    }
}

// MARK: - Parser

extension OCInterfaceParser {
    
    /// 解析类型定义
    /**
     classDecl = '@interface' className (':' className)* protocols
     className = NAME
     protocols = '<' NAME (',' NAME)* '>' | ''
     */
    var classParser: Parser<BPClassNode> {
        let lAngle = token(.leftAngle)
        let rAngle = token(.rightAngle)
        
    /*
        let parser = curry(BPClassNode.init)
            ~>* token(.interface) *> token(.name) ~>- go2String // 类名
            *<~ trying (token(.colon) *> token(.name)) ~>- go2String // 父类名
            *<~ trying (token(.name).separateBy(token(.comma)).between(lAngle, rAngle)) ~>- go2String
        return parser
       */
        
        let  parserClassName      = token(.interface) *> token(.name) ~>- go2String // 类名
        let  parserSuperClassName = trying (token(.colon) *> token(.name)) ~>- go2String // 父类名
        let  parserProtocols      = trying (token(.name).separateBy(token(.comma)).between(lAngle, rAngle)) ~>- go2String
        
        let goParser = curry(BPClassNode.init) ~>* parserClassName *<~ parserSuperClassName *<~ parserProtocols
        
        
        return goParser
        
        
        //执行顺序
        //1.curry(BPClassNode.init) ~>* parserClassName *<~ parserSuperClassName
        //2.curry(BPClassNode.init) ~>* parserClassName
        //3.parserClassName
        //4.token(.interface) *> token(.name)
        //5.token(.interface)
    }
    
    /// 解析分类定义
    /**
     extension = '@interface' className '(' NAME? ')' protocols
     className = NAME
     protocols = '<' NAME (',' NAME)* '>' | ''
     */
    var categoryParser: Parser<BPClassNode> {
        let lParen = token(.leftParen)
        let rParen = token(.rightParen)
        let lAngle = token(.leftAngle)
        let rAngle = token(.rightAngle)
        
        /*
        // @interface xx(xx?) <xx, xx>
        return curry(BPClassNode.init)
            ~>* token(.interface) *> token(.name) ~>- go2String
            *<~ trying(token(.name)).between(lParen, rParen) *> pure(nil) // 分类的名字是可选项, 忽略结果
            *<~ trying(token(.name).separateBy(token(.comma)).between(lAngle, rAngle)) ~>- go2String // 协议列表
        */
        
        

        let  parserClassName      = token(.interface) *> token(.name) ~>- go2String // 类名
        let  parserCat            = trying(token(.name)).between(lParen, rParen) *> pure("") //分类的名字 忽略掉
        let  parserProtocols      = trying(token(.name).separateBy(token(.comma)).between(lAngle, rAngle)) ~>- go2String // 协议列表
       
        let  goParser             = curry(BPClassNode.init) ~>* parserClassName *<~ parserCat *<~ parserProtocols
        return goParser
    }
}

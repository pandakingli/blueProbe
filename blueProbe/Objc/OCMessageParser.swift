//
//  OCMessageParser.swift
//  blueProbe
//
//  Created by lining on 2018/4/6.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

import Foundation
import Curry
import Runes

class OCMessageParser: ParserType {
    
    var parser: Parser<[BPInvokeNode]> {
        return messageSend.continuous.bluemap({ (methods) -> [BPInvokeNode] in
            var result = methods
            for method in methods {
                result.append(contentsOf: method.params.reduce([]) { $0 + $1.invokes })
            }
            return result
        })
    }
}

// MARK: - Parser

extension OCMessageParser {
    
    /// 解析一个方法调用
    /**
     message_send = '[' receiver param_selector ']'
     */
    var messageSend: Parser<BPInvokeNode> {
        let msg = curry(BPInvokeNode.ocInit)
            ~>* receiver
            *<~ paramSelector
        
        return msg.between(token(.leftSquare), token(.rightSquare)) <?> "message_send解析失败"
    }
    
    /// 调用方
    /**
     receiver = message_send | NAME
     */
    var receiver: Parser<MethodInvoker> {
        return  lazy(self.messageSend) ~>- toMethodInvoker() <|> token(.name) ~>- toMethodInvoker() <?> "receiver解析失败"
    }
    
    /// 参数列表
    /**
     param_selector = param_list | NAME
     */
    var paramSelector: Parser<[InvokeParam]> {
        return paramList <|> { [InvokeParam(name: $0.text, invokes: [])] } ~>* token(.name) <?> "param_selector解析失败"
    }
    
    /// 带具体参数的列表
    /**
     param_list = (param)+
     */
    var paramList: Parser<[InvokeParam]> {
        return param.many <?> "param_list解析失败"
    }
    
    /// 参数
    /**
     param = NAME ':' param_body
     */
    var param: Parser<InvokeParam> {
        return curry(InvokeParam.init)
            ~>* (curry({ "\($0.text)\($1.text)" }) ~>* token(.name) *<~ token(.colon))
            *<~ paramBody
    }
    
    /// 解析具体参数内容，参数中的方法调用也解析出来
    var paramBody: Parser<[BPInvokeNode]> {
        return { lazy(self.messageSend).continuous.run($0) ?? [] }
            ~>* anyOpenTokens(until: token(.rightSquare) <|> token(.name) *> token(.colon))
    }
}

// MARK: - Helper

extension OCMessageParser {
    func toMethodInvoker() -> (BPInvokeNode) -> MethodInvoker {
        return { invoke in
            .method(invoke)
        }
    }
    
    func toMethodInvoker() -> (Token) -> MethodInvoker {
        return { token in
            .name(token.text)
        }
    }
}

extension BPInvokeNode {
    static func ocInit(_ invoker: MethodInvoker, _ params: [InvokeParam]) -> BPInvokeNode {
        let invoke = BPInvokeNode()
        invoke.isSwift = false
        invoke.invoker = invoker
        invoke.params = params
        return invoke
    }
}

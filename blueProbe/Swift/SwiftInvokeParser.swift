//
//  SwiftInvokeParser.swift
//  blueProbe
//
//  Created by lining on 2018/4/6.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

import Foundation
import Curry
import Runes

class SwiftInvokeParser: ParserType {
    
    var parser: Parser<[BPInvokeNode]> {
        return methodInvoke.continuous.bluemap({ (methods) -> [BPInvokeNode] in
            var result = methods
            for method in methods {
                result.append(contentsOf: method.params.reduce([]) { $0 + $1.invokes })
            }
            return result
        })
    }
}

// MARK: - Parser

extension SwiftInvokeParser {
    
    /// method_invoke = single_method ('.' single_method)
    var methodInvoke: Parser<BPInvokeNode> {
        return singleMethod
            .separateBy(token(.dot))
            .blueFlat({ (methods) -> Parser<BPInvokeNode> in
                guard methods.count > 0 else {
                    return fail()
                }
                return pure(methods.dropFirst().reduce(methods[0]) { (last, current) in
                    current.invoker = .method(last)
                    return current
                })
            })
    }
    
    // FIXME: 尾随闭包
    /// 匹配一个单独的方法调用
    /// single_method = (invoker '.')? NAME '(' param_list? ')'
    var singleMethod: Parser<BPInvokeNode> {
        return curry(BPInvokeNode.swiftInit)
            ~>* token(.name) ~>- go2String // 方法名
            *<~ paramList.between(token(.leftParen), token(.rightParen)) // 参数列表
    }
    
    /// 解析一个参数列表, 该parser不会失败
    /**
     param_list = param (param ',')*
     */
    var paramList: Parser<[InvokeParam]> {
        // FIXME: 目前没有匹配数字，如 method(2) 这种情况无法正确解析参数个数
        return lookAhead(token(.rightParen)) *> pure([])
            <|> param.separateBy(token(.comma))
    }
    
    /// 解析单个参数，该parser不会失败
    /**
     param =  (NAME ':')? param_body
     */
    var param: Parser<InvokeParam> {
        return curry(InvokeParam.init)
            ~>* trying (token(.name) <* token(.colon)) ~>- go2String
            *<~ trying (paramBody) ?? []
    }
    
    /// 匹配参数体中的的方法调用，没有则为空
    var paramBody: Parser<[BPInvokeNode]> {
        return { lazy(self.singleMethod).continuous.run($0) ?? [] }
            ~>* anyOpenTokens(until: token(.rightParen) <|> token(.comma))
    }
}

extension BPInvokeNode {
    static func swiftInit(methodName: String, _ params: [InvokeParam]) -> BPInvokeNode {
        let invoke = BPInvokeNode()
        invoke.isSwift = true
        invoke.params = params
        invoke.methodName = methodName
        return invoke
    }
}

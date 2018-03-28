//
//  Operator.swift
//  blueProbe
//
//  Created by biubiu on 2018/2/26.
//  Copyright © 2018年 biubiublue. All rights reserved.
//


import Foundation
import Runes

precedencegroup ErrorMessagePrecedence
{
    associativity: left
    higherThan: LogicalConjunctionPrecedence
    lowerThan: ComparisonPrecedence
}

/**
 custom operator
 */
infix operator <?> : ErrorMessagePrecedence

func <?> <T>(_ parser: Parser<T>, _ err: String) -> Parser<T> {
    return Parser<T> { (tokens) -> Result<(T, Tokens)> in
        let result = parser.parse(tokens)
        if case .failure(let error) = result {
            return .failure(.custom("\(err): \(error)"))
        }
        return result
    }
}

/// parser结果为可选值，如果parser成功但结果为空则用defaultVal替换结果
func ?? <T>(_ parser: Parser<T?>, _ defaultVal: T) -> Parser<T> {
    return Parser<T> { (tokens) -> Result<(T, Tokens)> in
        switch parser.parse(tokens) {
        case .success(let (result, rest)):
            if let result = result {
                return .success((result, rest))
            } else {
                return .success((defaultVal, rest))
            }
        case .failure(let error):
            return .failure(error)
        }
    }
}

// MARK: - 类型转换操作符



// MARK: - 类型转换辅助方法

/// 将所有Token的text组合成一个字符串
let joinedText: ([Token]) -> String = { tokens in
    var strings = [String]()
    for token in tokens {
        strings.append(token.text)
    }
    return strings.joined()
}

/// 将所有Token的text组合成一个字符串, 以separator作为分隔符
func joinedText(_ separator: String) -> ([Token]) -> String {
    return { tokens in
        var strings = [String]()
        for token in tokens {
            strings.append(token.text)
        }
        return strings.joined(separator: separator)
    }
}

/// 将所有text组合成一个字符串, 以separator作为分隔符
func joinedText(_ separator: String) -> ([String]) -> String {
    return { texts in
        return texts.joined(separator: separator)
    }
}

/// 接收任意参数，包装在数组中返回
func array<T>() -> (T) -> [T] {
    return { t in
        [t]
    }
}

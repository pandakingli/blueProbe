//
//  blueOperators.swift
//  blueProbe
//
//  Created by lining on 2018/3/26.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

import Foundation
import Runes

precedencegroup ConvertPrecedence {
    associativity: left
    higherThan: RunesApplicativePrecedence
    lowerThan: RunesApplicativeSequencePrecedence
}


infix operator ~>- : ConvertPrecedence
func ~>- <T, U>(_ lhs: Parser<T>, _ transfrom: @escaping (T) -> U) -> Parser<U> {
    return lhs.bluemap { transfrom($0) }
}

func ~>- <T, U>(_ lhs: Parser<[T]>, _ transfrom: @escaping (T) -> U) -> Parser<[U]> {
    return lhs.bluemap { list in
        list.map { transfrom($0) }
    }
}

func ~>- <T, U>(_ lhs: Parser<[T]?>, _ transfrom: @escaping (T) -> U) -> Parser<[U]> {
    return lhs.bluemap { list in
        if let list = list {
            return list.map { transfrom($0) }
        } else {
            return []
        }
    }
}

var go2String: (Token?) -> String
{
    return {
              token in
                        if let token = token
                        {
                            return token.text
                        }
                        else
                        {
                            return ""
                        }
             }
}


infix operator *<~ : RunesApplicativePrecedence
/// 顺序执行两个parser，然后将右侧parser的结果应用到左侧返回的函数中
func *<~ <T, U>(lhs: Parser<(T) -> U>, rhs: Parser<T>) -> Parser<U> {
    return rhs.applyLeft(lhs)
}

infix operator ~>* : RunesApplicativePrecedence




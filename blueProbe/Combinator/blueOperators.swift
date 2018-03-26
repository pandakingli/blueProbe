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
/// 顺序执行两个parser，然后将右侧parser的结果应用到左侧返回的函数中 <*>
func *<~ <T, U>(lhs: Parser<(T) -> U>, rhs: Parser<T>) -> Parser<U>
{
    return rhs.applyLeft(lhs)
}

//<^>
infix operator ~>* : RunesApplicativePrecedence
func ~>* <T, U>(f: @escaping (T) -> U, p: Parser<T>) -> Parser<U> {
    return p.bluemap(f)
}

/// 顺序执行两个parser，最后直接抛弃左侧parser的结果，返回右侧parser的结果
func *> <T, U>(lhs: Parser<T>, rhs: Parser<U>) -> Parser<U> {
    return Parser<U> { (tokens) -> Result<(U, Tokens)> in
        let lresult = lhs.parse(tokens)
        guard let l = lresult.value else {
            return .failure(lresult.error!)
        }
        
        let rresult = rhs.parse(l.1)
        guard let r = rresult.value else {
            return .failure(rresult.error!)
        }
        
        return .success(r)
    }
}

/// 顺序执行两个parser，最后直接抛弃有侧parser的结果，返回左侧parser的结果
func <* <T, U>(lhs: Parser<T>, rhs: Parser<U>) -> Parser<T> {
    return Parser<T> { (tokens) -> Result<(T, Tokens)> in
        let lresult = lhs.parse(tokens)
        guard let l = lresult.value else {
            return .failure(lresult.error!)
        }
        
        let rresult = rhs.parse(l.1)
        guard let r = rresult.value else {
            return .failure(rresult.error!)
        }
        
        return .success((l.0, r.1))
    }
}

/// 左侧parser成功返回左侧的结果，否则返回右侧parser的结果
func <|> <T>(lhs: Parser<T>, rhs: Parser<T>) -> Parser<T> {
    return lhs.or(rhs)
}

extension Parser {
    func or(_ other: Parser<T>) -> Parser<T> {
        return Parser(parse: { (tokens) -> Result<(T, Tokens)> in
            let r = self.parse(tokens)
            switch r {
            case .success(_):
                return r
            case .failure(_):
                return other.parse(tokens) // 左侧失败时不消耗输入
            }
        })
    }
}


func >>- <T, U>(lhs: Parser<T>, rhs: @autoclosure @escaping (T) -> Parser<U>) -> Parser<U> {
    return lhs.flatMap(rhs)
}

func -<< <T, U>(lhs: @autoclosure @escaping (T) -> Parser<U>, rhs: Parser<T>) -> Parser<U> {
    return rhs.flatMap(lhs)
}

extension Parser {
    func flatMap<U>(_ f: @escaping (T) -> Parser<U>) -> Parser<U> {
        return Parser<U> { (tokens) -> Result<(U, Tokens)> in
      
            
            switch self.parse(tokens) {
            case .success(let (result, rest)):
                let p = f(result)
                return p.parse(rest)
                
            case .failure(let error):
                return .failure(error)
            }
        }
    }
}

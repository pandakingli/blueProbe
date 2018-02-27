//
//  Applicative.swift
//  blueProbe
//
//  Created by biubiu on 2018/2/26.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

import Foundation
import Runes

/// 顺序执行两个parser，然后将右侧parser的结果应用到左侧返回的函数中
func <*> <T, U>(lhs: Parser<(T) -> U>, rhs: Parser<T>) -> Parser<U> {
    return rhs.apply(lhs)
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

extension Parser {
    func apply<U>(_ parser: Parser<(T) -> U>) -> Parser<U> {
        return Parser<U> { (tokens) -> Result<(U, Tokens)> in
            let lresult = parser.parse(tokens)
            guard let l = lresult.value else {
                return .failure(lresult.error!)
            }
            
            let rresult = self.parse(l.1)
            guard let r = rresult.value else {
                return .failure(rresult.error!)
            }
            
            return .success((l.0(r.0), r.1))
        }
    }
}

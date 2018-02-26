//
//  ParserType.swift
//  blueProbe
//
//  Created by lining on 2018/2/24.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

import Foundation

import Foundation

enum ParserError: Error {
    case missMatch(String)
    case custom(String)
    case unknown
}

protocol Node { } // AST节点

protocol ParserType {
    associatedtype T
    var parser: Parser<T> { get }
}

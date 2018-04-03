//
//  BPMethodNode.swift
//  blueProbe
//
//  Created by lining on 2018/4/3.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

import Foundation
import SwiftHash
// MARK: - Param

struct Param {
    var outterName: String  // 参数的名字
    var type: String  // 参数类型
    var innerName: String  // 内部形参的名字
}

// MARK: - MethodNode

/// 方法定义
class BPMethodNode: Node {
    var isSwift = false  // 是否为swift方法
    var isStatic = false  // 是否为类方法
    var returnType: String = "" // 返回值类型
    var methodName: String = "" // 方法的名字
    var params: [Param] = [] // 方法的参数
    var invokes: [BPInvokeNode] = [] // 方法体中调用的方法
}

// MARK: - 初始化方法

extension BPMethodNode {
    /// OC初始化方法
    class func ocInit(_ isStatic: Bool, _ retType: String, _ params: [Param], _ invokes: [BPInvokeNode]) -> BPMethodNode {
        let method = BPMethodNode()
        
        method.isSwift = false
        method.isStatic = isStatic
        method.returnType = retType
        method.params = params
        method.invokes = invokes
        
        return method
    }
    
    /// swift初始化方法
    class func swiftInit(_ isStatic: Bool, _ name: String, _ params: [Param], _ retType: String, _ invokes: [BPInvokeNode]) -> BPMethodNode {
        let method = BPMethodNode()
        
        method.isSwift = true
        method.isStatic = isStatic
        method.returnType = retType
        method.methodName = name
        method.params = params
        method.invokes = invokes
        
        return method
    }
}

// MARK: - 数据格式化

extension BPMethodNode: CustomStringConvertible {
    var description: String {
        if isSwift {
            return swiftDescription
        } else {
            return objcDescription
        }
    }
    
    /// 格式化成OC风格
    var objcDescription: String {
        var method = "\(isStatic ? "+" : "-") ["
        
        let methodDesc = params.join(go2String: { (param) -> String in
            if !param.innerName.isEmpty {
                return "\(param.outterName):"
            } else {
                return param.outterName
            }
        }, separator: " ")
        method.append(contentsOf: "\(methodDesc)]")
        
        return method
    }
    
    /// 格式化成swift风格
    var swiftDescription: String {
        var method = ""
        
        if methodName != "init" {
            method.append(contentsOf: "func ")
        }
        method.append(contentsOf: "\(methodName)(")
        
        if isStatic {
            method.insert(contentsOf: "static ", at: method.startIndex)
        }
        
        let paramStr = params.join(go2String: { (param) -> String in
            return "\(param.outterName.isEmpty ? "_" : param.outterName): "
        }, separator: ", ")
        method.append(contentsOf: "\(paramStr))")
        
        return method
    }
}

extension BPMethodNode {
    /// 将方法转化成JSON字典
    func toJson(clsId: String, methods: [Int]) -> [String: Any] {
        var info: [String: Any] = [:]
        info["type"] = "method"                         // type
        info["classId"] = clsId                         // classId
        info["static"] = self.isStatic                  // static
        info["isSwift"] = self.isSwift                  // isSwift
        
        if isSwift {
            info["name"] = methodName                   // name
        }
        
        info["returnType"] = returnType                 // returnType
        info["id"] = IDA_MD5("\(clsId)\(self.hashValue)") // 类id加上自身的id作为方法的id
     
        
        // 参数
        var paramInfo: [[String: String]] = []
        for param in params {
            paramInfo.append(["type": param.type, "sel": param.outterName, "name": param.innerName])
        }
        info["params"] = paramInfo                      // params
        
        // 调用的方法
        var invokeInfos: [[String: String]] = []
        var set = Set<BPInvokeNode>() // 去重
        for invoke in invokes {
            if set.contains(invoke) {
                continue
            }
            // 如果调用的是自身的方法
            if methods.contains(invoke.hashValue) {
                invokeInfos.append([
                    "methodId": IDA_MD5("\(clsId)\(invoke.hashValue)"),
                    "classId": clsId
                    ])
            } else {
                invokeInfos.append(["formatedName": invoke.description])
            }
            set.insert(invoke)
        }
        info["invokes"] = invokeInfos                   // invokes
        
        return info
    }
}

// MARK: - Hashable

extension BPMethodNode: Hashable {
    
    static func ==(_ left: BPMethodNode, _ right: BPMethodNode) -> Bool {
        return left.hashValue == right.hashValue
    }
    
    /// 目前swift和oc之间不能判等
    var hashValue: Int {
        if isSwift {
            return swiftHashValue
        } else {
            return objcHashValue
        }
    }
    
    var objcHashValue: Int {
        var value = ""
        for param in params {
            value.append(contentsOf: param.outterName)
            if !param.innerName.isEmpty {
                value.append(contentsOf: ":")
            }
        }
        return value.hashValue
    }
    
    var swiftHashValue: Int {
        let paramSign = params.join(go2String: { (param) -> String in
            return "\(param.outterName):"
        }, separator: ",")
        let methodSign = "\(methodName)\(paramSign)"
        
        return methodSign.hashValue
    }
}

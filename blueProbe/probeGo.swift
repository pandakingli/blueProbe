//
//  probeGo.swift
//  blueProbe
//
//  Created by lining on 2018/2/24.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

import Foundation


let maxConcurrent: Int = 4  //多线程

class Drafter {
 
    var bp_paths: String = "" {
       
        didSet {
            
            let pathValues = bp_paths.split(separator: ",")
            
    
                for path in pathValues {
                    
                    var isDir: ObjCBool = ObjCBool.init(false)
                    
                    if FileManager.default.fileExists(atPath: String(path), isDirectory: &isDir) {
                      
                        
                        if isDir.boolValue, let enumerator = FileManager.default.enumerator(atPath: String(path)) {
                            
                            while let file = enumerator.nextObject() as? String {
                                
                                if supported(file)
                                {
                                    files.append("\(path)/\(file)")
                                }
                                
                            }
                            
                            
                        }
                        else
                        {
                            files = [String(path)]
                        }
                    }
                    else
                    {
                        print("File: \(path) not exist")
                    }
                }
        }
    }

    
    // MARK: - Private
    
    fileprivate var files: [String] = []
    fileprivate let semaphore = DispatchSemaphore(value: maxConcurrent)
    
    fileprivate func supported(_ file: String) -> Bool {
        if file.hasSuffix(".h") || file.hasSuffix(".m") || file.hasSuffix(".swift") {
            return true
        }
        return false
    }
    
    fileprivate func createInheritGraph() {
       
        var classes = [ClassNode]()
        var protocols = [ProtocolNode]()
        let writeQueue = DispatchQueue(label: "WriteClass")
        
        // 解析OC类型
        func parseObjcClass(_ file: String) {
            print("Parsing \(file)...")
            let tokens = SourceLexer(file: file).allTokens
            let result = InterfaceParser().parser.run(tokens) ?? []
            writeQueue.sync {
                classes.merge(result)
            }
        }
        
        // 解析swift类型
        func parseSwiftClass(_ file: String) {
            print("Parsing \(file)...")
            let tokens = SourceLexer(file: file).allTokens
            let (protos, cls) = SwiftInheritParser().parser.run(tokens) ?? ([], [])
            writeQueue.sync {
                protocols.append(contentsOf: protos)
                classes.merge(cls)
            }
        }
        
        // 解析OC文件
        for file in files.filter({ !$0.isSwift }) {
            semaphore.wait()
            DispatchQueue.global().async {
                parseObjcClass(file)
                self.semaphore.signal()
            }
        }
        
        // 解析swift文件
        for file in files.filter({ $0.isSwift }) {
            semaphore.wait()
            DispatchQueue.global().async {
                parseSwiftClass(file)
                self.semaphore.signal()
            }
        }
        
        waitUntilFinished()
        
        classes = classes.filter({ ($0.className.contains(keywords))||($0.superCls?.contains(keywords))! })
        //protocols = protocols.filter({ $0.name.contains(keywords) })
        
        let resultPath = DotGenerator.generate(classes: classes, protocols: [], filePath: "Inheritance")
        /*
         // Log result
         for node in classes {
         print(node)
         }
         
         Executor.execute("open", resultPath, help: "Auto open failed")
         */
    }
    
    /// 生成方法调用关系图
    fileprivate func craftinvokeGraph() {
        func parseMethods(_ file: String) -> String {
            print("Parsing \(file)...")
            let tokens = SourceLexer(file: file).allTokens
            
            var nodes = [MethodNode]()
            if file.isSwift {
                let result = SwiftMethodParser().parser.run(tokens) ?? []
                nodes.append(contentsOf: filted(result))
            } else {
                let result = ObjcMethodParser().parser.run(tokens) ?? []
                nodes.append(contentsOf: filted(result))
            }
            
            return DotGenerator.generate(nodes, filePath: file)
        }
        
        var resultPaths = [String]()
        for file in files.filter({ !$0.hasSuffix(".h") }) {
            semaphore.wait()
            DispatchQueue.global().async {
                resultPaths.append(parseMethods(file))
                self.semaphore.signal()
            }
        }
        
        waitUntilFinished()
        
        // 如果只有一张图片则自动打开
        if resultPaths.count == 1 {
            Executor.execute("open", resultPaths[0], help: "Auto open failed")
        }
    }
    
    /// 等待直到所有任务完成
    func waitUntilFinished() {
        for _ in 0..<maxConcurrent {
            semaphore.wait()
        }
        for _ in 0..<maxConcurrent {
            semaphore.signal()
        }
    }
}

// MARK: - 过滤方法

fileprivate extension Drafter {
    
    func filted(_ methods: [MethodNode]) -> [MethodNode] {
        var methods = methods
        methods = filtedSelfMethod(methods)
        methods = extractSubtree(methods)
        return methods
    }
    
    /// 仅保留自定义方法之间的调用
    func filtedSelfMethod(_ methods: [MethodNode]) -> [MethodNode] {
        if selfOnly {
            var selfMethods = Set<Int>()
            for method in methods {
                selfMethods.insert(method.hashValue)
            }
            
            return methods.map({ (method) -> MethodNode in
                var selfInvokes = [MethodInvokeNode]()
                for invoke in method.invokes {
                    if selfMethods.contains(invoke.hashValue) {
                        selfInvokes.append(invoke)
                    }
                }
                method.invokes = selfInvokes
                return method
            })
        }
        return methods
    }
    
    /// 根据关键字提取子树
    func extractSubtree(_ nodes: [MethodNode]) -> [MethodNode] {
        guard keywords.count != 0, nodes.count != 0 else {
            return nodes
        }
        
        // 过滤出包含keyword的根节点
        var subtrees: [MethodNode] = []
        let filted = nodes.filter {
            $0.description.contains(keywords)
        }
        subtrees.append(contentsOf: filted)
        
        // 递归获取节点下面的调用分支
        func selfInvokes(_ invokes: [MethodInvokeNode], _ subtrees: [MethodNode]) -> [MethodNode] {
            guard invokes.count != 0 else {
                return subtrees
            }
            
            let methods = nodes.filter({ (method) -> Bool in
                invokes.contains(where: { $0.hashValue == method.hashValue }) &&
                    !subtrees.contains(where: { $0.hashValue == method.hashValue })
            })
            
            return selfInvokes(methods.reduce([], { $0 + $1.invokes}), methods + subtrees)
        }
        
        subtrees.append(contentsOf: selfInvokes(filted.reduce([], { $0 + $1.invokes}), subtrees))
        
        return subtrees
    }
    
}

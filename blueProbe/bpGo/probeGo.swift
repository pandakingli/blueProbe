//
//  probeGo.swift
//  blueProbe
//
//  Created by lining on 2018/2/24.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

import Foundation
import Cocoa

let maxConcurrent: Int = 4  //多线程

class probeGo {
    
    var keywords: [String] = []
    var styleStr: String = "dot"
    var outStr: String = "svg"
     var selfOnly: Bool = false // 只包含定义在用户代码中的方法节点
    var bp_paths: String = "" { didSet { setUpFiles() }  }

     ///bp_paths属性变化后，处理一下
    func setUpFiles()
    {
        let pathValues = bp_paths.split(separator: ",")
        
        files.removeAll()
        
        for path in pathValues
        {
            
            var isDir: ObjCBool = ObjCBool.init(false)
            
            if FileManager.default.fileExists(atPath: String(path), isDirectory: &isDir)
            {
                
                    if isDir.boolValue, let enumerator = FileManager.default.enumerator(atPath: String(path))
                    {
                        
                        while let file = enumerator.nextObject() as? String
                        {
                            
                            if supported(file)
                            {
                                files.append("\(path)/\(file)")
                            }
                            
                        }//while
                        
                    }
                    else
                    {
                        files = [String(path)]
                    }
                
            } //if FileManager.default
            else
            {
                print("File: \(path) not exist")
            }
        }
        
    }//func setUpFiles()
    
    func doMakeG() {
      BPSettingCenter.sharedInstance.setStart()
        switch BPSettingCenter.sharedInstance.mode
        {
            case .inheritGO:
                createInheritGraph()
            
            case .invokeGO:
                createInheritGraph()
        }
        
    }
    func filted(_ methods: [BPMethodNode]) -> [BPMethodNode] {
        var methods = methods
        methods = filtedSelfMethod(methods)
        methods = extractSubtree(methods)
        return methods
    }
    /// 仅保留自定义方法之间的调用
    func filtedSelfMethod(_ methods: [BPMethodNode]) -> [BPMethodNode] {
        if selfOnly {
            var selfMethods = Set<Int>()
            for method in methods {
                selfMethods.insert(method.hashValue)
            }
            
            return methods.map({ (method) -> BPMethodNode in
                var selfInvokes = [BPInvokeNode]()
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
    func extractSubtree(_ nodes: [BPMethodNode]) -> [BPMethodNode] {
        guard keywords.count != 0, nodes.count != 0 else {
            return nodes
        }
        
        // 过滤出包含keyword的根节点
        var subtrees: [BPMethodNode] = []
        let filted = nodes.filter {
            $0.description.contains(keywords)
        }
        subtrees.append(contentsOf: filted)
        
        // 递归获取节点下面的调用分支
        func selfInvokes(_ invokes: [BPInvokeNode], _ subtrees: [BPMethodNode]) -> [BPMethodNode] {
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
       
        var classes = [BPClassNode]()
        var protocols = [BPProtocolNode]()
        let writeQueue = DispatchQueue(label: "WriteClass")
        
        // 解析OC类型
        func parseObjcClass(_ file: String) {
            print("Parsing \(file)...")
            let tokens = SourceLexer(file: file).allTokens
            let result = OCInterfaceParser().parser.run(tokens) ?? []
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
                BPSettingCenter.sharedInstance.addObjc()
                self.semaphore.signal()
            }
        }
        
        // 解析swift文件
        for file in files.filter({ $0.isSwift }) {
            semaphore.wait()
            DispatchQueue.global().async {
                parseSwiftClass(file)
                BPSettingCenter.sharedInstance.addSwift()
                self.semaphore.signal()
            }
        }
        
        waitUntilFinished()
        
        //获取父类 Set 供选择
        BPSettingCenter.sharedInstance.filterSet.removeAllObjects()
        BPSettingCenter.sharedInstance.setEnd()
        for item in classes
        {
            if (item.superKlass != nil)
            {
                BPSettingCenter.sharedInstance.filterSet.add(item.superKlass!)
            }
        }
        
        let  arr = NSMutableArray()
        
        for item in BPSettingCenter.sharedInstance.filterSet {
            arr.add(item)
        }
        
     
        BPSettingCenter.sharedInstance.kClasses = classes
        
        DispatchQueue.main.async(execute: {
            
            BPSettingCenter.sharedInstance.resetSuperSelect(arr)
            BPSettingCenter.sharedInstance.showAlert()
            
        })
        
        /*
        var ccArr:[BPClassNode]=[]
         goFilterWithBNode(goclassArr: &ccArr,
                           nodeKclass: "NSObject",
                           classArr: classes)
        
        //classes = classes.filter({ ($0.klassName.contains(keywords))||($0.superKlass?.contains(keywords))! })
        //protocols = protocols.filter({ $0.name.contains(keywords) })
       
        
        GraphMaker.generate(classes: ccArr,
                            protocols: [],
                            filePath: self.bp_paths+"/Inheritance",
                            styleStr: self.styleStr,
                            outStr: self.outStr)
  
       
         GoMaker.execute("open", self.bp_paths, help: "Auto open failed")
 */
    }
    
  fileprivate func createInvokeGraph()
  {
  
    let results = parseMethods(files: files)
    

    var outputFiles = [String]()
    for (file, nodes) in results
    {
        outputFiles.append(GraphMaker.Gogenerate(filted(nodes), filePath: file))
    }
    

    if outputFiles.count == 1
    {
        GoMaker.execute("open", outputFiles[0], help: "Auto open failed")
    }
}
    
    
    func parseMethods(files: [String]) -> [String: [BPMethodNode]]
    {
        var results = [String: [BPMethodNode]]()
        
        func runParse(_ file: String) -> [BPMethodNode]
        {
            print("Parsing \(file)...")
            let tokens = SourceLexer(file: file).allTokens
            var nodes = [BPMethodNode]()
            
            if file.isSwift
            {
                let result = SwiftMethodParser().parser.run(tokens) ?? []
                nodes.append(contentsOf: result)
            }
            else
            {
                let result = OCMethodParser().parser.run(tokens) ?? []
                nodes.append(contentsOf: result)
            }
            return nodes
        }
        
        // 1. 解析方法调用
        let sources = files.filter({ !$0.hasSuffix(".h") })
        for file in sources {
            semaphore.wait()
            DispatchQueue.global().async {
                results[file] = runParse(file)
                self.semaphore.signal()
            }
        }
        
        waitUntilFinished()
        
        return results
    }
    
    func goDoBNode()
    {
        var ccArr:[BPClassNode]=[]
        let center = BPSettingCenter.sharedInstance
        goFilterWithBNode(goclassArr: &ccArr,
                          nodeKclass: center.keyClassName!,
                          classArr: center.kClasses)
        
        GraphMaker.generate(classes: ccArr,
                            protocols: [],
                            filePath: center.bp_paths+"/Inheritance",
                            styleStr: center.styleType,
                            outStr: center.outPutFile)
        
        
        GoMaker.execute("open", self.bp_paths, help: "Auto open failed")
    }

    /// 筛选节点
    ///
    /// - Returns: 返回数组
    func goFilterWithBNode( goclassArr:inout [BPClassNode],nodeKclass:String,classArr:[BPClassNode])
    {
        
        for item in classArr
        {
            if item.klassName == nodeKclass
            {
                goclassArr.append(item)
            }
            else if item.superKlass ==  nodeKclass
            {
                goFilterWithBNode(goclassArr: &goclassArr,
                                  nodeKclass: item.klassName,
                                  classArr: classArr)
            }
            
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



//
//  probeGo.swift
//  blueProbe
//
//  Created by lining on 2018/2/24.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

import Foundation


let maxConcurrent: Int = 4  //多线程

class probeGo {
    
    var keywords: [String] = []
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

    func doMakeG() {
      
        createInheritGraph()
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
        
        classes = classes.filter({ ($0.klassName.contains(keywords))||($0.superKlass?.contains(keywords))! })
        //protocols = protocols.filter({ $0.name.contains(keywords) })
        
        let resultPath = GraphMaker.generate(classes: classes, protocols: [], filePath: self.bp_paths+"/Inheritance")
        
    
        
        
        
        /*
         // Log result
         for node in classes {
         print(node)
         }
         
         Executor.execute("open", resultPath, help: "Auto open failed")
         */
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



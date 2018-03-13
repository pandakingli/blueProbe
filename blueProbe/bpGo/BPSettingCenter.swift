//
//  BPSettingCenter.swift
//  blueProbe
//
//  Created by lining on 2018/3/13.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

import Cocoa

class BPSettingCenter: NSObject {

    var mainWindowC :MainWC = MainWC()
    var mode: makeBPMode = .inheritGO
    var keyClassName: String? = nil
    /// dot还是neato 等
    var styleType: String = "dot"
    
    /// 输出文件的格式 pdf,svg,png等
    var outPutFile: String = "svg"
    
    /// 方向：TB：上下，LR：左右
    var tblr: String = "TB"
    
    /// 是否带协议
    var haveProtocols: Bool = false
    
    var filterSet:NSMutableSet = NSMutableSet()
    var kClasses = [BPClassNode]()
    
    static let sharedInstance = BPSettingCenter()
    private override init() {}
    
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
    
    fileprivate var files: [String] = []
    fileprivate let semaphore = DispatchSemaphore(value: maxConcurrent)
    
    fileprivate func supported(_ file: String) -> Bool {
        if file.hasSuffix(".h") || file.hasSuffix(".m") || file.hasSuffix(".swift") {
            return true
        }
        return false
    }
}

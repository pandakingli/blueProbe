//
//  MainWC.swift
//  blueProbe
//
//  Created by lining on 2018/1/26.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

import Cocoa

let kStyleItems = ["dot","neato","fdp","sfdp","twopi","circo"]
let kOutPutItems = ["svg","png","pdf","bmp","gif","jpeg","jpg","ico","json","psd","tiff","webp"]

class MainWC: NSWindowController {

    @IBOutlet weak var outButton: NSPopUpButton!
    @IBOutlet weak var styleButton: NSPopUpButton!
    @IBOutlet weak var pathstr: NSTextField!

    let openPP = NSOpenPanel()
    let gMaker = probeGo()
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.backgroundColor = NSColor.white
        self.window?.title = "蓝色探针"
        
        self.outButton.removeAllItems()
        self.outButton.addItems(withTitles: kOutPutItems)
        self.outButton.selectItem(at: 0)
        
        self.styleButton.removeAllItems()
        self.styleButton.addItems(withTitles: kStyleItems)
        self.styleButton.selectItem(at: 0)
        
    }
    
 
    @IBAction func getPathBtn(_ sender: Any) {
        
        
        openPP.allowsMultipleSelection = false
        openPP.canChooseDirectories    = true
        openPP.canChooseFiles          = false
        openPP.directoryURL = URL.init(string: NSHomeDirectory())
        openPP.begin(completionHandler: { (result) in
            
            if result.rawValue == NSFileHandlingPanelOKButton {

                print("NSFileHandlingPanelOKButton")
                print(self.openPP.url?.path as Any)
                self.pathstr.stringValue = (self.openPP.url?.path)!
                
            }
            
            if result.rawValue == NSFileHandlingPanelCancelButton {
                
                print("NSFileHandlingPanelCancelButton")
                
                
            }

            
        })

        
    }
    
    @IBAction func quitBtn(_ sender: Any) {
        exit(0)
    }
    @IBAction func makeGraphBtn(_ sender: Any) {
        
        
        
        gMaker.keywords = []
        //gMaker.mode = .inheritGraph
        //gMaker.selfOnly = false
        gMaker.styleStr = (self.styleButton.selectedItem?.title)!
        gMaker.outStr = (self.outButton.selectedItem?.title)!
        gMaker.bp_paths = self.pathstr.stringValue
        gMaker.doMakeG()
        
        
        
    }
    
}

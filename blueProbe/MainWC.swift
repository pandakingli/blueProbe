//
//  MainWC.swift
//  blueProbe
//
//  Created by lining on 2018/1/26.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

import Cocoa
import Lottie
enum makeBPMode: NSInteger {
    
    case inheritGO = 0
    case invokeGO  = 1
    
}
let kTBLRItems = ["左右","上下","右左","下上"]
let kModeItems = ["继承图","调用图"]
let kStyleItems = ["dot","neato","fdp","sfdp","twopi","circo"]
let kOutPutItems = ["svg","png","pdf","bmp","gif","jpeg","jpg","ico","json","psd","tiff","webp"]

class MainWC: NSWindowController {


    @IBOutlet weak var protoCheck: NSButton!
    @IBOutlet weak var tblrButton: NSPopUpButton!
    @IBOutlet weak var superSelect: NSPopUpButton!
    @IBOutlet weak var modeSelectBtn: NSPopUpButton!
    @IBOutlet weak var outButton: NSPopUpButton!
    @IBOutlet weak var styleButton: NSPopUpButton!
    @IBOutlet weak var pathstr: NSTextField!

    
    let openPP = NSOpenPanel()
    let gMaker = probeGo()
    let animationView = LOTAnimationView(name: "pencil_write")
    
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
        
        self.modeSelectBtn.removeAllItems()
        self.modeSelectBtn.addItems(withTitles: kModeItems)
        self.modeSelectBtn.selectItem(at: 0)
        
        self.tblrButton.removeAllItems()
        self.tblrButton.addItems(withTitles: kTBLRItems)
        self.tblrButton.selectItem(at: 0)

        let wwRect = self.window?.contentView?.bounds
        
        let rect = NSRect(x:190, y: 270, width: 100, height: 100)
        self.animationView.frame = rect
        
        
        self.window?.contentView?.addSubview(self.animationView)
      
        self.animationView.isHidden = false
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
    
    
    @IBAction func analyseBtn(_ sender: Any) {
        
     
       self.startRunningAni()
        
        var  center  = BPSettingCenter.sharedInstance

        center.styleType     = self.styleButton.selectedItem!.title
        center.outPutFile    = self.outButton.selectedItem!.title
        center.bp_paths      = self.pathstr.stringValue

       self.updateTBLR()

        center.mode          = makeBPMode(rawValue: self.modeSelectBtn.indexOfSelectedItem)!
        center.mainWindowC = self

        gMaker.bp_paths = center.bp_paths
        gMaker.doMakeG()
        
    }
    
    @IBAction func makeGraphBtn(_ sender: Any) {
        
        self.stopRunningAni()
        self.updateTBLR()
        BPSettingCenter.sharedInstance.keyClassName = self.superSelect.selectedItem!.title

        gMaker.goDoBNode()
//
    }
    
    func startRunningAni()
    {
        self.animationView.isHidden = false
        self.animationView.loopAnimation = true
        self.animationView.play()
        
    }
    func stopRunningAni()
    {
        self.animationView.isHidden = true
        self.animationView.loopAnimation = false
        self.animationView.stop()
    }
    func updateTBLR()  {
      
        let center  = BPSettingCenter.sharedInstance
        
        var tblr = "LR"
        switch self.tblrButton.indexOfSelectedItem
        {
        case 0:
            tblr = "LR"
        case 1:
            tblr = "TB"
        case 2:
            tblr = "RL"
        case 3:
            tblr = "BT"
        default:
            tblr = "LR"
        }
        
        center.tblr = tblr
        
        if self.protoCheck.state.rawValue>0
        {
            center.haveProtocols = true
        }
    }
    
}

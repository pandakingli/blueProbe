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
    let animationViewDef = AnimationView(name: "dna_like_loader")
    let animationView = AnimationView(name: "material_wave_loading")
    let animationViewDone = AnimationView(name: "checked_done_")
    
    // MARK: windowDidLoad
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.backgroundColor = NSColor.gray
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

        self.superSelect.removeAllItems()
        self.superSelect.addItems(withTitles: ["NSObject"])
        self.superSelect.selectItem(at: 0)
        
        let rect = NSRect(x:190, y: 260, width: 100, height: 100)
        self.animationViewDone.frame = rect
        self.animationView.frame = rect
        
        let rrect = NSRect(x:140, y: 280, width: 200, height: 45)
        
        self.animationViewDef.frame=rrect
        
        self.window?.contentView?.addSubview(self.animationViewDone)
        self.window?.contentView?.addSubview(self.animationView)
        self.window?.contentView?.addSubview(self.animationViewDef)
        
        self.animationViewDone.isHidden = true
        self.animationView.isHidden = true
        self.animationViewDef.isHidden = false
        
        self.animationViewDef.loopMode = LottieLoopMode.loop
        
        self.animationViewDef.play()
        
        let center  = BPSettingCenter.sharedInstance
        
        let hiString = center.getKeyPath()
        
        if hiString != nil {
            self.pathstr.stringValue = (hiString)!
        }
        
    }
    
    // MARK: 获取路径
    @IBAction func getPathBtn(_ sender: Any) {
        
        openPP.allowsMultipleSelection = false
        openPP.canChooseDirectories    = true
        openPP.canChooseFiles          = false
        openPP.directoryURL = URL.init(string: NSHomeDirectory())
        openPP.begin(completionHandler: { (result) in
            
            if result.rawValue == NSFileHandlingPanelOKButton {

                print("NSFileHandlingPanelOKButton-确定")
                print(self.openPP.url?.path as Any)
                self.pathstr.stringValue = (self.openPP.url?.path)!
                let center  = BPSettingCenter.sharedInstance
                
                self.superSelect.removeAllItems()
                self.superSelect.addItems(withTitles: ["NSObject"] )
                self.superSelect.selectItem(at: 0)
                
                center.cleanAll()
                center.saveKeyPath(kPath: self.pathstr.stringValue)
            }
            
            if result.rawValue == NSFileHandlingPanelCancelButton {
                print("NSFileHandlingPanelCancelButton-取消")
            }

        })

    }
    
    // MARK: 退出按钮
    @IBAction func quitBtn(_ sender: Any) {
        exit(0)
    }
    
    // MARK: 分析按钮
    @IBAction func analyseBtn(_ sender: Any) {
        
     
       self.startRunningAni()
        
        let  center  = BPSettingCenter.sharedInstance

        center.styleType     = self.styleButton.selectedItem!.title
        center.outPutFile    = self.outButton.selectedItem!.title
        center.bp_paths      = self.pathstr.stringValue

       self.updateTBLR()

        center.mode          = makeBPMode(rawValue: self.modeSelectBtn.indexOfSelectedItem)!
        center.mainWindowC = self

        gMaker.bp_paths = center.bp_paths
  
        let globalQueue = DispatchQueue.global()
        globalQueue.async {
            self.gMaker.doMakeG()
        }
    }
    
    // MARK: 开始制图
    @IBAction func makeGraphBtn(_ sender: Any) {
        
        self.stopRunningAni()
        self.updateTBLR()
        BPSettingCenter.sharedInstance.keyClassName = self.superSelect.selectedItem!.title
        if self.superSelect.selectedItem!.title == "全部" {
            BPSettingCenter.sharedInstance.keyClassName = nil
        }
        gMaker.goDoBNode()

    }
    
    // MARK: 开始动画
    func startRunningAni(){
        self.animationViewDef.isHidden = true
        self.animationViewDef.stop()
        
        self.animationViewDone.isHidden = true
        self.animationView.isHidden = false
        self.animationView.loopMode = LottieLoopMode.loop
        self.animationView.play()
        
    }
    
    // MARK: 停止动画
    func stopRunningAni(){
        self.animationViewDef.isHidden = true
        self.animationViewDef.stop()
        
        self.animationView.isHidden = true
        self.animationView.loopMode = LottieLoopMode.loop
        self.animationView.stop()
        
        self.animationViewDone.isHidden=false
        self.animationViewDone.play()
    }
    
     // MARK: 获取制图方向
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
        center.haveProtocols =  self.protoCheck.state.rawValue>0
    }
    
}

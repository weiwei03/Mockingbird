//
//  MockingbirdScanCodeManager.swift
//  Mockingbird
//
//  Created by xiangwenwen on 15/6/15.
//  Copyright (c) 2015年 xiangwenwen. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class MockingbirdScanCodeManager:UIViewController,AVCaptureMetadataOutputObjectsDelegate{
    
    var captureSession:AVCaptureSession?
    var globalColor:UIColor?
    var globalTitle:String?
    var previewLineColor:UIColor?
    
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var videoPreviewLineAnimationFrameView:UIView?
    var videoPreviewContainsFrameView:UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.title = self.globalTitle == nil ? "扫描条码" : self.globalTitle
        self.handlerViewColor()
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error:NSError?
        let input:AnyObject! = AVCaptureDeviceInput.deviceInputWithDevice(captureDevice, error: &error)
        if error != nil{
            println("\( error?.localizedDescription)")
        }else{
            self.captureSession = AVCaptureSession()
            self.captureSession?.addInput(input as! AVCaptureInput)
            let captureMetadataOutput = AVCaptureMetadataOutput()
            self.captureSession?.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeQRCode]
            self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            self.videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
            self.videoPreviewLayer?.frame = self.view.bounds
            self.view.layer.addSublayer(self.videoPreviewLayer)
            self.captureSession?.startRunning()
            self.createUIView()
            println("scan code init")
        }
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0{
            self.videoPreviewContainsFrameView?.frame = CGRectZero
            println("No QR code is detected")
            return
        }
        let metadata = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if  metadata.type == AVMetadataObjectTypeQRCode{
            let barCode = self.videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadata) as! AVMetadataMachineReadableCodeObject
            self.videoPreviewContainsFrameView?.frame = barCode.bounds
            if metadata.stringValue != nil{
                println(metadata.stringValue)
                NSNotificationCenter.defaultCenter().postNotificationName(MOKNotifiScanResult, object: nil, userInfo: ["value":metadata.stringValue])
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }else{
            let barCode = self.videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadata) as! AVMetadataMachineReadableCodeObject
            self.videoPreviewContainsFrameView?.frame = barCode.bounds
            NSNotificationCenter.defaultCenter().postNotificationName(MOKNotifiScanResult, object: nil, userInfo: ["value":metadata.stringValue])
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    private func createUIView()->Void{
        self.videoPreviewContainsFrameView = UIView(frame: CGRectMake(MOKWidth/4, (MOKHeight-200)/2, MOKWidth/2, 200))
        self.videoPreviewContainsFrameView?.layer.borderColor = self.globalColor == nil ? MOKOrchid.CGColor : self.globalColor!.CGColor
        self.videoPreviewContainsFrameView?.layer.borderWidth = 1
        self.view.addSubview(self.videoPreviewContainsFrameView!)
        self.view.bringSubviewToFront(self.videoPreviewContainsFrameView!)
        self.videoPreviewLineAnimationFrameView = UIView(frame: CGRectMake(0, 0, MOKWidth/2, 1))
        self.videoPreviewLineAnimationFrameView?.layer.borderWidth = 1
        self.videoPreviewLineAnimationFrameView?.layer.borderColor = self.previewLineColor == nil ? MOKSnow.CGColor : self.previewLineColor?.CGColor
        self.videoPreviewContainsFrameView?.addSubview(self.videoPreviewLineAnimationFrameView!)
        self.videoPreviewLineAnimation()
        var time:NSTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(2.0), target: self, selector: "repetitionScanAnimation", userInfo: nil, repeats: true)
        let reminder = UILabel(frame: CGRectMake(0, MOKHeight-80, MOKWidth, 40))
        reminder.textAlignment = NSTextAlignment.Center
        reminder.textColor = MOKSnow
        reminder.text = "对准要扫描的条码"
        reminder.font = UIFont.systemFontOfSize(25.0)
        self.view.addSubview(reminder)
        self.view.bringSubviewToFront(reminder)
    }
    
    func videoPreviewLineAnimation()->Void{
        let animation = CABasicAnimation(keyPath: "MOK")
        animation.duration = 2.0
        animation.keyPath = "position.y"
        animation.toValue = 200-1
        self.videoPreviewLineAnimationFrameView?.layer.addAnimation(animation, forKey: "MOK")
    }
    
    func repetitionScanAnimation()->Void{
        self.videoPreviewLineAnimation()
    }
    
    private func handlerViewColor()->Void{
        if let color = self.globalColor{
           self.navigationController?.navigationBar.barTintColor = color
        }
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
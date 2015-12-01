//
//  ScanViewController.swift
//  YGScanViewController
//
//  Created by C on 15/9/29.
//  Copyright © 2015年 YoungKook. All rights reserved.
//  二维码扫描

import UIKit
import AVFoundation


class ScanViewController: UIViewController {

    let screenWidth = UIScreen.mainScreen().bounds.size.width
    let screenHeight = UIScreen.mainScreen().bounds.size.height
    let screenSize = UIScreen.mainScreen().bounds.size
    
    
    var traceNumber = 0
    var upORdown = false
    var timer:NSTimer!
    
    var device : AVCaptureDevice!           //代表了物理捕获设备如:摄像机。用于配置等底层硬件设置相机的自动对焦模式。
    var input  : AVCaptureDeviceInput!      //创建输入流
    var output : AVCaptureMetadataOutput!   //创建输出流
    var session: AVCaptureSession!          //输入输出的中间桥梁
    var preView: AVCaptureVideoPreviewLayer!
    var line   : UIImageView!
    
    var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "二维码扫描"
        
        if !setupCamera() {
            return
        }
        setupScanLine()
    }

    func setupCamera() -> Bool {
        // 获取设备
        device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        do {
            input = try AVCaptureDeviceInput(device: device)
        }
        catch let error as NSError {
            print(error.localizedDescription)
            return false
        }
        
        output = AVCaptureMetadataOutput()
        // 设置代理 在主线程里刷新
        output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        // rectOfInterest设置可扫描区域
        output.rectOfInterest = makeScanReaderInterestRect()
        //初始化链接对象
        session = AVCaptureSession()
        //高质量采集率
        session.sessionPreset = AVCaptureSessionPresetHigh
        
        if session.canAddInput(input)
        {
            session.addInput(input)
        }
        if session.canAddOutput(output)
        {
            session.addOutput(output)
        }
        //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]
        
        preView = AVCaptureVideoPreviewLayer(session: session)
        preView.videoGravity = AVLayerVideoGravityResizeAspectFill
        preView.frame = self.view.bounds
        
        let shadowView = makeScanCameraShadowView(makeScanReaderRect())
        self.view.layer.insertSublayer(preView, atIndex: 0)
        self.view.addSubview(shadowView)
        
        return true
    }
    
    func makeScanReaderRect() -> CGRect {
        let scanSize = (min(screenWidth, screenHeight) * 3) / 4
        var scanRect = CGRectMake(0, 0, scanSize, scanSize)
        
        scanRect.origin.x += (screenWidth / 2) - (scanRect.size.width / 2)
        scanRect.origin.y += (screenHeight / 2) - (scanRect.size.height / 2) - 50 //整个扫描区域上下移动改变50即可
        
        return scanRect
    }
    
    // 返回可扫描区域x，y互换 width，height互换，很奇葩
    func makeScanReaderInterestRect() -> CGRect {
        let rect = makeScanReaderRect()
        let x = rect.origin.x / screenWidth
        let y = rect.origin.y / screenHeight
        let width = rect.size.width / screenWidth
        let height = rect.size.height / screenHeight
        
        return CGRectMake(y, x, height, width)
    }
    
    // 背景阴影半透明黑色
    func makeScanCameraShadowView(innerRect: CGRect) -> UIView {
        let referenceImage = UIImageView(frame: self.view.bounds)
        
        UIGraphicsBeginImageContext(referenceImage.frame.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetRGBFillColor(context, 0, 0, 0, 0.7)
        var drawRect = CGRectMake(0, 0, screenWidth, screenHeight)
        CGContextFillRect(context, drawRect)
        drawRect = CGRectMake(innerRect.origin.x, innerRect.origin.y, innerRect.size.width, innerRect.size.height)
        print(drawRect)
        CGContextClearRect(context, drawRect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        referenceImage.image = image
        
        return referenceImage
    }
    
    // MARK: 定时器
    
    func scanLineAnimation() {
        let rect = makeScanReaderRect()
        
        let lineFrameX = rect.origin.x
        let lineFrameY = rect.origin.y
        let downHeight = rect.size.height
        
        if upORdown == false {
            traceNumber++
            line.frame = CGRectMake(lineFrameX, lineFrameY + CGFloat(2 * traceNumber), downHeight, 2)
            if CGFloat(2 * traceNumber) > downHeight - 2 {
                upORdown = true
            }
        }
        else
        {
            traceNumber--
            line.frame = CGRectMake(lineFrameX, lineFrameY + CGFloat(2 * traceNumber), downHeight, 2)
            if traceNumber == 0 {
                upORdown = false
            }
        }
    }
    func setupScanLine() {
        let rect = makeScanReaderRect()
        
        var imageSize: CGFloat = 20.0
        let imageX = rect.origin.x
        let imageY = rect.origin.y
        let width = rect.size.width
        let height = rect.size.height + 2
        
        /// 四个边角
        let imageViewTL = UIImageView(frame: CGRect(x: imageX, y: imageY, width: imageSize, height: imageSize))
        imageViewTL.image = UIImage(named: "scan_1")
        imageSize = (imageViewTL.image?.size.width)!
        self.view.addSubview(imageViewTL)
        
        let imageViewTR = UIImageView(frame: CGRect(x: imageX + width - imageSize, y: imageY, width: imageSize, height: imageSize))
        imageViewTR.image = UIImage(named: "scan_2")
        self.view.addSubview(imageViewTR)
        
        let imageViewBL = UIImageView(frame: CGRect(x: imageX, y: imageY + height - imageSize, width: imageSize, height: imageSize))
        imageViewBL.image = UIImage(named: "scan_3")
        self.view.addSubview(imageViewBL)
        
        let imageViewBR = UIImageView(frame: CGRect(x: imageX + width - imageSize, y: imageY + height - imageSize, width: imageSize, height: imageSize))
        imageViewBR.image = UIImage(named: "scan_4")
        self.view.addSubview(imageViewBR)
        
        line = UIImageView(frame: CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, 2))
        line.image = UIImage(named: "scan_net")
        self.view.addSubview(line)
        
        label = UILabel(frame: CGRect(x: 0, y: imageY + height + 20, width: UIScreen.mainScreen().bounds.width, height: 20))
        label.textAlignment = .Center
        label.text = "将二维码/条码放入框内,即可自动扫描"
        label.textColor = UIColor.whiteColor()
        self.view.addSubview(label)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        session.startRunning()
        timer = NSTimer(timeInterval: 0.02, target: self, selector: "scanLineAnimation", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
    }
    
    override func viewWillDisappear(animated: Bool) {
        traceNumber = 0
        upORdown = false
        session.stopRunning()
        timer.invalidate()
        timer = nil
        super.viewWillDisappear(animated)
    }
    
    // MARK: show result
    func showScanCode(code: String) {
        //TODO: ===========   判断二维码码号   ===========
        session.stopRunning()
        label.text = code
        delay(3) {
            self.session.startRunning()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    // MARK: AVCaptureMetadataOutputObjectsDelegate
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)   // 震动
        if metadataObjects.count == 0 {
            return
        }
        let metadata = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        let value = metadata.stringValue
        showScanCode(value)
    }
}

typealias Task = (cancel: Bool) -> ()
func delay(time: NSTimeInterval, task:() -> ()) -> Task?{
    func dispatch_later(block: () -> ()){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(time * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), block)
    }
    var closure: dispatch_block_t? = task
    var result: Task?
    let delayClosure: Task = {
        cancel in
        if let internalClosure = closure {
            if cancel == false {
                dispatch_async(dispatch_get_main_queue(), internalClosure)
            }
        }
        closure = nil
        result = nil
    }
    result = delayClosure
    
    dispatch_later { () -> () in
        if let delayClosure = result {
            delayClosure(cancel: false)
        }
    }
    return result
}
func cancel(task: Task?){
    task?(cancel: true)
}
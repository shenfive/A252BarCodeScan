//
//  ViewController.swift
//  A252BarCodeScan
//
//  Created by 申潤五 on 2025/4/13.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var outputLabel: UILabel!
    @IBOutlet weak var videoPreview: UIView!
    
    @IBOutlet weak var reScanButton: UIButton!
    let avCaptureSession = AVCaptureSession()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDevice()
        print("keep working")
        reScanButton.isHidden = true
    }
    
    func setupDevice(){
        //檢查是否有預設輸入設備，沒有輸入設備就中斷
        guard let avCaptureDevice =
                AVCaptureDevice.default(for: AVMediaType.video) else {  return  }
        //試試看影像設備是否被佔用，若正常的話它就是輸入設備，否則中斷
        guard  let avCaptureInput =
                try? AVCaptureDeviceInput(device: avCaptureDevice) else {  return }
        // 一切正常，就可加入輸入設備
        avCaptureSession.addInput(avCaptureInput)  //session 加上輸入
        
        //建立一個輸出物件，並設定 ViewController 為接受代理人
        let avCaptureMetadataOutput = AVCaptureMetadataOutput()
        //輸出時，使用主線程
        avCaptureMetadataOutput
            .setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        //session 加上輸出
        avCaptureSession.addOutput(avCaptureMetadataOutput)
        //加上支援的類別，這必需要加入 session 之後再做，不然會閃退
        avCaptureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr, AVMetadataObject.ObjectType.code128, AVMetadataObject.ObjectType.code39, AVMetadataObject.ObjectType.code93, AVMetadataObject.ObjectType.upce, AVMetadataObject.ObjectType.pdf417, AVMetadataObject.ObjectType.ean13, AVMetadataObject.ObjectType.aztec]
        // 先建一個 UIView 做為輸出的影像，把圖層加到畫面中的圖層中，讓使用者可以看到
        let avCaptureVidoePreviewLayer = AVCaptureVideoPreviewLayer(session: avCaptureSession)
        avCaptureVidoePreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        avCaptureVidoePreviewLayer.frame = videoPreview.bounds
        self.videoPreview.layer.addSublayer(avCaptureVidoePreviewLayer)
        //第一次啟動
        avCaptureSession.startRunning()

    }

    @IBAction func reScan(_ sender: Any) {
        avCaptureSession.startRunning()
    }
    
}

extension ViewController:AVCaptureMetadataOutputObjectsDelegate{
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
         if metadataObjects.count > 0 {
             let machineReabableCode =
 metadataObjects[0] as! AVMetadataMachineReadableCodeObject
             outputLabel.text = machineReabableCode.stringValue
             reScanButton.isHidden = false
             avCaptureSession.stopRunning()
         }
     }

    
}


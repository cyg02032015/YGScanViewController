//
//  ViewController.swift
//  YGScanViewController
//
//  Created by C on 15/12/1.
//  Copyright © 2015年 YoungKook. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "系统自带QRCode"
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func scanButtonClick(sender: AnyObject) {
        let scanVC = ScanViewController()
        navigationController?.pushViewController(scanVC, animated: true)
    }


}


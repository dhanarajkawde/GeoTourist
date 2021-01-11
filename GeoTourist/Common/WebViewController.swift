//
//  WebViewController.swift
//  GeoTourist
//
//  Created by Dhanraj Kawade on 11/01/21.
//

import UIKit
import WebKit

/// class to Open URL
class WebViewController: BaseViewController {

    // MARK:- IB Outlets
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var webViw: WKWebView!
        
    // MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.webViw.loadFileURL(BaseViewController.logFile!, allowingReadAccessTo: BaseViewController.logFile!)
    }
    
    /// Go back to home controller
    /// - Parameter sender: sender description
    @IBAction func btnBackClicked(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }

}

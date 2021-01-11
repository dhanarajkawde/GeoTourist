//
//  BaseViewController.swift
//  GeoTourist
//
//  Created by Dhanraj Kawade on 05/01/21.
//

import UIKit

/// Base class of UIViewController
class BaseViewController: UIViewController {
    // MARK:- Variavle Declaration
    var alert = UIAlertController()
    static var logFile: URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let fileName = "logFile.txt"
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    // MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let _ = BaseViewController.logFile
        
        print("Lat=\(LocationSingleton.shared.getLatitude()), Long=\(LocationSingleton.shared.getLongitude()), Time=\(Date())")
        _ = Timer.scheduledTimer(timeInterval: 900.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }
    
    /// call timer to detect location after 15 minutes
    @objc func fireTimer() {
        self.alert.dismiss(animated: false, completion: nil)
        self.showInformativeAlert(title: Localizable.YourLocation, msg: "Lat=\(LocationSingleton.shared.getLatitude()), Long=\(LocationSingleton.shared.getLongitude()), Time=\(Date())")
        print("\(Localizable.Lat)=\(LocationSingleton.shared.getLatitude()), \(Localizable.Long)=\(LocationSingleton.shared.getLongitude()), \(Localizable.Time)=\(Date())")
        BaseViewController.logEvent("\(Localizable.Lat)=\(LocationSingleton.shared.getLatitude()), \(Localizable.Long)=\(LocationSingleton.shared.getLongitude()), \(Localizable.Time)=\(Date())")
    }
    
    /// Show common alert
    /// - Parameters:
    ///   - title: title description
    ///   - msg: msg description
    func showInformativeAlert(title:String, msg:String) {
        
        DispatchQueue.main.async {
            
            self.alert = UIAlertController.init(title: title, message: msg, preferredStyle: .alert)
            
            let okAction = UIAlertAction.init(title: Localizable.OK, style: .default, handler:nil)
            self.alert.addAction(okAction)
            self.present(self.alert, animated: true, completion: nil)
        }
    }
    
    /// Save logs in file
    /// - Parameter message: message description
    static func logEvent(_ message: String) {
        guard let logFile = logFile else {
            return
        }
        
        guard let data = (message + "\n").data(using: String.Encoding.utf8) else { return }
        
        let _ = BaseViewController.readEvent { (log) in
            
            var arrLog = log.split(separator: "\n")
                                 
            if arrLog.count == 10 {
                arrLog.remove(at: 0)
                BaseViewController.makeEmptyFile()
                
                for l in arrLog {
                    
                    guard let data = (l + "\n").data(using: String.Encoding.utf8) else { return }
                    
                    if FileManager.default.fileExists(atPath: logFile.path) {
                        if let fileHandle = try? FileHandle(forWritingTo: logFile) {
                            fileHandle.seekToEndOfFile()
                            fileHandle.write(data)
                            fileHandle.closeFile()
                        }
                    } else {
                        try? data.write(to: logFile, options: .atomicWrite)
                    }
                }
            }
            else {
                if FileManager.default.fileExists(atPath: logFile.path) {
                    if let fileHandle = try? FileHandle(forWritingTo: logFile) {
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(data)
                        fileHandle.closeFile()
                    }
                } else {
                    try? data.write(to: logFile, options: .atomicWrite)
                }
            }
        }
    }
    
    /// Read log file
    /// - Parameter completion: completion description
    static func readEvent(completion: @escaping (String) -> Void) {
        guard let logFile = logFile else {
            return
        }
        
        do {
            let text2 = try String(contentsOf: logFile)
            completion(text2)
        }
        catch {
            print(error.localizedDescription)
            completion("")
        }
    }
    
    /// Make file empty
    static func makeEmptyFile() {
        let text = ""
        do {
            try text.write(to: BaseViewController.logFile!, atomically: false, encoding: .utf8)
        } catch {
            print(error)
        }
    }
}

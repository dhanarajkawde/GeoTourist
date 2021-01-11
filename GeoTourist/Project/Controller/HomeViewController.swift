//
//  HomeViewController.swift
//  GeoTourist
//
//  Created by Dhanraj Kawade on 05/01/21.
//

import UIKit
import CoreData

/// class to show list of tours and landing controller
class HomeViewController: BaseViewController {
    
    // MARK:- IB Outlets
    @IBOutlet weak var tblTourList: UITableView!
    @IBOutlet weak var btnCreateTour: UIButton!
    @IBOutlet weak var viwBack: UIView!
    
    // MARK:- Variavle Declaration
    var arrTour = [Tour]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        self.tblTourList.register(UINib(nibName: Constants.TourListTableViewCell, bundle: .main), forCellReuseIdentifier: Constants.TourListTableViewCell)
        self.tblTourList.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.loadSavedGroupOfFriendData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.viwBack.layer.cornerRadius = 5
        self.viwBack.addShadow(offset: CGSize(width: 1.0, height: 1.0), color: UIColor.darkGray, radius: 3, opacity: 0.3)
    }
    
    /// Send to create tour screen to add new Tour
    /// - Parameter sender: sender description
    @IBAction func btnCreateTourClicked(_ sender: UIButton) {
        
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: Constants.Main, bundle: nil)
            let createTourViewController:CreateTourViewController = storyboard.instantiateViewController(identifier: Constants.CreateTourViewController)
            self.navigationController?.pushViewController(createTourViewController, animated: true)
        }
    }
    
    /// Check logs of location
    /// - Parameter sender: sender description
    @IBAction func btnCheckLogsClicked(_ sender: UIButton) {
        
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: Constants.Main, bundle: nil)
            let webViewController:WebViewController = storyboard.instantiateViewController(identifier: Constants.WebViewController)
            self.navigationController?.pushViewController(webViewController, animated: true)
        }
    }
    
    /// Load saved data from Core Data
    /// - Parameter request: request description
    func loadSavedGroupOfFriendData(request:NSFetchRequest<Tour> = Tour.fetchRequest()) {
        
        do {
            self.arrTour = try context.fetch(request)
            self.tblTourList.reloadData()
        }
        catch {
            
            print("error fetching context")
        }
    }
}

// MARK:- UITableViewDelegate, UITableViewDataSource
extension HomeViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrTour.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tourListTableViewCell:TourListTableViewCell = tableView.dequeueReusableCell(withIdentifier: Constants.TourListTableViewCell, for: indexPath) as! TourListTableViewCell
        tourListTableViewCell.lblName.text = self.arrTour[indexPath.row].tourName
        
        return tourListTableViewCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                
        let storyboard = UIStoryboard(name: Constants.Main, bundle: nil)
        let viewTourViewController:ViewTourViewController = storyboard.instantiateViewController(identifier: Constants.ViewTourViewController)
        viewTourViewController.tourDetail = self.arrTour[indexPath.row]
        self.navigationController?.pushViewController(viewTourViewController, animated: true)
    }
}

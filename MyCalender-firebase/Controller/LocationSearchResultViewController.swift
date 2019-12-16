//
//  LocationSearchResultViewController.swift
//  MyCalendar
//
//  Created by DKS_mac on 2019/12/2.
//  Copyright © 2019 dks. All rights reserved.
//

import UIKit
import MapKit

protocol HandleLocationSelect {
    func dropPinZoomIn(placemark: MKPlacemark)
}

class LocationSearchResultViewController: UITableViewController {

    // 搜索结果
    var matchingItems: [MKMapItem] = []
    // 搜索中心位置
    var searchCenter: CLLocationCoordinate2D?
    
    var delegate: HandleLocationSelect?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return matchingItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
        
        // Configure the cell...
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        let address = "\(selectedItem.thoroughfare ?? ""), \(selectedItem.locality ?? ""), \(selectedItem.subLocality ?? ""), \(selectedItem.administrativeArea ?? ""), \(selectedItem.postalCode ?? ""), \(selectedItem.country ?? "")"
        cell.detailTextLabel?.text = address

        return cell
    }
    
    // 选中一个搜索结果后添加标记并显示在地图上
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        delegate?.dropPinZoomIn(placemark: selectedItem)
        dismiss(animated: true, completion: nil)
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LocationSearchResultViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // matchingItems.removeAll()
        guard let searchBarText = searchController.searchBar.text else {
            return
        }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        // request.region = mapView.region
        let span = MKCoordinateSpan(latitudeDelta: 180, longitudeDelta: 360)        // 全球范围搜索
        if let userLocation = searchCenter {
            request.region = MKCoordinateRegion(center: userLocation, span: span)
        }
        let search = MKLocalSearch(request: request)
        search.start(completionHandler: { (response, _) in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        })
    }
    
    
}

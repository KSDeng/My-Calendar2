

import UIKit
import MapKit
import CoreLocation


// References:
// https://medium.com/@pravinbendre772/search-for-places-and-display-results-using-mapkit-a987bd6504df
// https://www.youtube.com/watch?v=GYzNsVFyDrU          // search for places in map kit


// MARK: TODOs
// 使用当前位置时产生比较友好的信息

protocol SetLocationHandle {
    func setLocation(location: MKPlacemark)
    func editLocationDone(location: MKPlacemark)
}

enum State: String{
    case add, show, edit, normal
}

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    // 位置管理器
    let locationManager = CLLocationManager()
    
    // 经度和纬度方向的初始显示范围(单位:米)
    // let regionRadius: CLLocationDistance = 5000
    
    // 搜索控制器
    var searchController: UISearchController? = nil
    // 用户位置
    var userLoction: CLLocationCoordinate2D?
    // 选择的位置
    var locationSelected: MKPlacemark?
    
    var delegate:SetLocationHandle?
    
    // Map当前状态
    var state = State.normal
    
    // 展示状态设置变量
    var showTitle: String?
    var showLongitude: Double?
    var showLatitude: Double?
    
    // 加载搜索结果的展示页面
    let locationResultTable = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "LocationSearchResultView") as! LocationSearchResultViewController
    
    override func viewWillAppear(_ animated: Bool) {
        mapView.delegate = self
        
        if state == .add {
            // 设置并请求当前位置
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.requestWhenInUseAuthorization()     // 请求运行时的位置信息使用权
            locationResultTable.delegate = self
            locationResultTable.searchCenter = userLoction
        } else if state == .edit {
            // print("My state is edit")
            locationManager.delegate = self
            locationResultTable.delegate = self
            if let long = showLongitude, let lat = showLatitude {
                locationResultTable.searchCenter = CLLocationCoordinate2D(latitude: lat, longitude: long)
            }
            
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if state == .add {
            setupSearchBar()
            
            setupConfirmButton()
            
            navigationItem.title = "选择地点"
        } else if state == .show {
            
            if let title = showTitle, let long = showLongitude, let lat = showLatitude {
                navigationItem.title = title
                
                let eventPlace = CLLocationCoordinate2D(latitude: lat, longitude: long)
                let annotation = MKPointAnnotation()
                annotation.title = title
                annotation.coordinate = eventPlace
                mapView.addAnnotation(annotation)
                centerMapOnLocation(location: eventPlace, latSpan: 0.1, longSpan: 0.1)
                
            }
        } else if state == .edit {
            setupSearchBar()
            setupConfirmButton()
            if let title = showTitle, let long = showLongitude, let lat = showLatitude {
                navigationItem.title = "当前地点:\(title)"
                
                let eventPlace = CLLocationCoordinate2D(latitude: lat, longitude: long)
                let annotation = MKPointAnnotation()
                annotation.title = title
                annotation.coordinate = eventPlace
                mapView.addAnnotation(annotation)
                centerMapOnLocation(location: eventPlace, latSpan: 0.1, longSpan: 0.1)
                
            }
        }
        
    }
    
    private func setupConfirmButton(){
        let confirmButton = UIBarButtonItem(title: "确定", style: .plain, target: self, action: #selector(confirmButtonClicked))
        navigationItem.rightBarButtonItem = confirmButton
    }
    
    @objc func confirmButtonClicked(){
        if let loc = locationSelected {
            if state == .add {
                delegate?.setLocation(location: loc)
            } else if state == .edit {
                delegate?.editLocationDone(location: loc)
            }
        }else{
            print("No location selected error!")
        }
        navigationController?.popViewController(animated: true)
    }
    
    // 配置搜索栏
    private func setupSearchBar(){
        searchController = UISearchController(searchResultsController: locationResultTable)
        searchController?.searchResultsUpdater = locationResultTable
        
        // 将搜索框嵌入导航栏
        let searchBar = searchController?.searchBar
        searchBar?.sizeToFit()
        searchBar?.placeholder = "搜索地点"
        
        navigationItem.searchController = searchController
        
        searchController?.hidesNavigationBarDuringPresentation = true
        searchController?.obscuresBackgroundDuringPresentation = true
        //searchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
    }
    // 将地图聚焦到某个范围，参数为位置坐标、纬度范围、经度范围
    func centerMapOnLocation(location: CLLocationCoordinate2D, latSpan: Double, longSpan: Double) {
        /*
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        */
        let span = MKCoordinateSpan(latitudeDelta: latSpan, longitudeDelta: longSpan)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // 获得允许之后请求当前位置
        if status == .authorizedWhenInUse && state == .add {
            locationManager.requestLocation()
        }
    }
    
    // 处理请求位置的结果
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            userLoction = location.coordinate
            centerMapOnLocation(location: location.coordinate, latSpan: 0.1, longSpan: 0.1)
        }
    }
    
    // 请求位置发生错误时调用(必须实现否则会发生SIGABRT异常)
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
}

extension MapViewController: HandleLocationSelect {
    func dropPinZoomIn(placemark: MKPlacemark) {
        locationSelected = placemark
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.title = placemark.name
        annotation.coordinate = placemark.coordinate
        mapView.addAnnotation(annotation)
        centerMapOnLocation(location: placemark.coordinate, latSpan: 0.1, longSpan: 0.1)
        navigationItem.title = placemark.name
    }
    
}

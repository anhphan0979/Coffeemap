//
//  MapViewController.swift
//  CoffeeMap
//
//  Created by Phan Tiến Anh on 7/16/20.
//  Copyright © 2020 Phan Tiến Anh. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth
import SDWebImage



class MapViewController: UIViewController, CLLocationManagerDelegate{
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var bottomLayoutCollectionView: NSLayoutConstraint!
    @IBOutlet weak var leftLayoutTableView: NSLayoutConstraint!
    @IBOutlet weak var rightLayoutTableView: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingimg: UIImageView!
    var ref = Database.database().reference()
    var currentLocation: CLLocationCoordinate2D?
    var locationManager: CLLocationManager!
    var mainLocation: Location?
    var subLocations: [SubLocation] = []
    var text: String = ""
    var destination: CLLocationCoordinate2D?
    var arrSetting: [Setting] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initLocation()
        self.navigationController?.navigationBar.isTranslucent = false
        mapView.showsUserLocation = true // Hiện vị trí user
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationItem.hidesBackButton = true
        let nib1 = UINib(nibName: "PinCollectionViewCell", bundle: .main)
        collectionView.register(nib1, forCellWithReuseIdentifier: "PinCell")
        let nib2 = UINib(nibName: "SettingTableViewCell", bundle: .main)
        tableView.register(nib2, forCellReuseIdentifier: "SettingCell")
        
        // Thêm dữ liệu cho tableview Setting
        self.arrSetting.append(Setting(img: "locationst", title: "Turn Off User Location"))
        self.arrSetting.append(Setting(img: "darkmodest", title: "Dark Mode"))
        self.arrSetting.append(Setting(img: "sharest", title: "Share App"))
        self.arrSetting.append(Setting(img: "changepassst", title: "Change Password"))
        self.arrSetting.append(Setting(img: "logoutst", title: "Log Out"))
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last?.coordinate
        guard let currentlocation = self.currentLocation else {return}
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: currentlocation, span: span)
        self.mapView.setRegion(region, animated: true)
    }
    
   func initLocation() {
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = .greatestFiniteMagnitude
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }

}

// mapView
extension MapViewController: MKMapViewDelegate {
    
    // Hàm thêm Pin
    func addPin(location: SubLocation){
        self.destination = CLLocationCoordinate2D(latitude: location.lat ?? 0.0, longitude: location.long ?? 0.0)
        mapView.removeAnnotations(mapView.annotations)
        let pin = MKPointAnnotation()
        pin.coordinate = CLLocationCoordinate2D(latitude: location.lat ?? 0, longitude: location.long ?? 0)
        pin.title = self.text
        mapView.addAnnotation(pin)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: pin.coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
        
    }
    
    // Kích vào pin
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if bottomLayoutCollectionView.constant == 0 {
            self.hideCollectionView()
        } else {
            self.showCollectionView()
        }
    }
    
    // Hàm vẽ đường
    func routing(source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination, addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .automobile
        let directions = MKDirections(request: request)
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            for route in unwrappedResponse.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    // Hàm vẽ đường
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 3
            return renderer
        } else if let circle = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: circle)
            circleRenderer.fillColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.5)
            circleRenderer.strokeColor = .blue
            circleRenderer.lineWidth = 1
            circleRenderer.lineDashPhase = 10
            return circleRenderer
        } else {
            return MKOverlayRenderer()
        }
    }
    
    //Hàm xoá chỉ đường
    func removeOverlay() {
        let overlays = mapView.overlays
        mapView.removeOverlays(mapView.overlays)
    }
    
    // Hàm tìm điểm gần nhất
    func findMinLocation(locations: [SubLocation]) -> (SubLocation?, Int) {
        guard locations.count > 0 else {return (nil,0)}
        var minDistane = locations[0].distance ?? 0
        var index = 0
        for (idx, loca) in locations.enumerated() {
            if loca.distance ?? 0.0 < minDistane {
                minDistane = loca.distance ?? 0
                index = idx
            }
        }
        return (locations[index],index)
    }
    
}

// SearchBar
extension MapViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        var searchtext = searchBar.text!
        self.text = searchtext
        if !searchtext.isEmpty {
            self.subLocations.removeAll()
            ref.child(searchtext).observeSingleEvent(of: .value, with: {(snapshot) in
                guard let data = snapshot.value as? [[String: Any]] else {return}
                guard let currentLocation = self.currentLocation else {return}
//                print(data)
                for i in data {
                    let lat = i["Lat"] as? Double
                    let long = i["Long"] as? Double
                    let address = i["Address"] as? String
                    let closetime = i["Close"] as? String
                    let opentime = i["Open"] as? String
                    let image = i["Image"] as? String
                    let loc = CLLocation(latitude: lat ?? 0.0, longitude: long ?? 0.0)
                    // Tính khoảng cách từng điểm
                    let distance = loc.distance(from: CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude))
                    let subLocation = SubLocation(lat: lat,
                                                  long: long,
                                                  distance: distance,
                                                  opentime: opentime,
                                                  closetime: closetime,
                                                  address: address,
                                                  image: image,
                                                  name: self.text)
                    self.subLocations.append(subLocation)
                }
                self.collectionView.reloadData()
                // Tìm điểm gần nhất
                self.mainLocation = Location(title: self.text, locations: self.subLocations)
                guard let mainLocation = self.mainLocation, mainLocation.locations.count > 0 else {return}
                let locationIndex = self.findMinLocation(locations:mainLocation.locations)
                if let minLocation = locationIndex.0 {
                    if minLocation.distance ?? 0 > 0 {
                        self.addPin(location: minLocation)
                        self.showCollectionView()
                        self.scrollToIndex(index: locationIndex.1)
                    }
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
}
    //SEARCH NAME, ID
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if !searchText.isEmpty {
//            self.subLocations.removeAll()
//            self.text = searchText
//            let t = self.text
//            ref.child(t).observeSingleEvent(of: .value, with: {(snapshot) in
//                guard let data = snapshot.value as? [[String: Any]] else {return}
//                guard let currentLocation = self.currentLocation else {return}
//                print(data)
//                for i in data {
//                    let lat = i["Lat"] as? Double
//                    let long = i["Long"] as? Double
//                    let address = i["Address"] as? String
//                    let closetime = i["Close"] as? String
//                    let opentime = i["Open"] as? String
//                    let image = i["Image"] as? String
//                    let loc = CLLocation(latitude: lat ?? 0.0, longitude: long ?? 0.0)
//                    // Tính khoảng cách từng điểm
//                    let distance = loc.distance(from: CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude))
//                    let subLocation = SubLocation(lat: lat,
//                                                  long: long,
//                                                  distance: distance,
//                                                  opentime: opentime,
//                                                  closetime: closetime,
//                                                  address: address,
//                                                  image: image,
//                                                  name: self.text)
//                    self.subLocations.append(subLocation)
//                }
//                self.collectionView.reloadData()
//                // Tìm điểm gần nhất
//                self.mainLocation = Location(title: self.text, locations: self.subLocations)
//                guard let mainLocation = self.mainLocation, mainLocation.locations.count > 0 else {return}
//                let locationIndex = self.findMinLocation(locations:mainLocation.locations)
//                if let minLocation = locationIndex.0 {
//                    if minLocation.distance ?? 0 > 0 {
//                        self.addPin(location: minLocation)
//                        self.showCollectionView()
//                        self.scrollToIndex(index: locationIndex.1)
//                    }
//                }
//            }) { (error) in
//                print(error.localizedDescription)
//            }
//        }
//    }
    


// CollectionView
extension MapViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // Hàm hiện CollectionView
       func showCollectionView() {
           self.bottomLayoutCollectionView.constant = 0
           UIView.animate(withDuration: 0.3) {
               self.view.layoutIfNeeded()
           }
       }
       
       // Hàm ẩn CollectionView
       func hideCollectionView() {
            self.bottomLayoutCollectionView.constant = -290
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
       }
    
    // Nút Close
    @IBAction func closeCollectionView() {
        self.hideCollectionView()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.subLocations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PinCell", for: indexPath) as! PinCollectionViewCell
        let item = self.subLocations[indexPath.row]
        cell.namelbl.text = item.name
        cell.addresslbl.text = item.address
        cell.opentimelbl.text = item.opentime
        cell.closetimelbl.text = item.closetime
        cell.img.sd_setImage(with: URL(string: item.image ?? ""))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
        UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let cell = self.collectionView.visibleCells.first else {return}
        guard let indexOfLocation = collectionView.indexPath(for: cell)?.row else {return}
        let visibleLocation = self.subLocations[indexOfLocation]
//        debugPrint("visibleLocation:\(visibleLocation)")
        self.addPin(location: visibleLocation)
        self.removeOverlay()
    }
    
    func scrollToIndex(index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        collectionView?.scrollToItem(at: indexPath, at: .right, animated: true)
    }
    
    // Nút Tìm Đường
    @IBAction func findRoad() {
        self.removeOverlay()
        routing(source: self.currentLocation ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), destination: self.destination ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
    }
    
}

// Table View
extension MapViewController: UITableViewDelegate, UITableViewDataSource {
        
    func showTableView() {
        rightLayoutTableView.constant = 0
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func hideTableView() {
        rightLayoutTableView.constant = 414
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }

    
    @IBAction func clickTbl() {
        if rightLayoutTableView.constant == 0 {
            self.hideTableView()
        }else {
            self.showTableView()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.arrSetting.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingTableViewCell
        let item = arrSetting[indexPath.row]
        cell.icon.image = UIImage(named: item.img ?? "")
        cell.lblTitleSetting.text = item.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 51.0//Choose your custom row height
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            if mapView.showsUserLocation == true {
                mapView.showsUserLocation = false
            } else {
                mapView.showsUserLocation = true
            }
        case 1:
            UIApplication.shared.windows.forEach { window in
                if window.overrideUserInterfaceStyle == .dark {
                    window.overrideUserInterfaceStyle = .light
                } else {
                    window.overrideUserInterfaceStyle = .dark
                }
            }
        case 2:
            let text = "This is the text....."
            let textShare = [ text ]
            let activityViewController = UIActivityViewController(activityItems: textShare , applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        case 3:
            let vc = CPasswordViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        case 4:
            do {
                try Auth.auth().signOut()
                    self.navigationController?.popViewController(animated: true)
                }
                catch let signOutError as NSError {
                       print ("Error signing out: %@", signOutError)
                   }
        default:
            print("0")
        }
    }
}



struct Location {
    var title: String
    var locations: [SubLocation]
}

struct SubLocation {
    var lat: Double?
    var long: Double?
    var distance: Double?
    var opentime: String?
    var closetime: String?
    var address: String?
    var image: String?
    var name: String?
}

struct Setting {
    var img: String?
    var title: String?
}

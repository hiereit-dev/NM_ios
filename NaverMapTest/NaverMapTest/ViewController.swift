//
//  ViewController.swift
//  NaverMapTest
//
//  Created by 박세라 on 2022/03/03.

import UIKit
import CoreLocation
import NMapsMap

class ViewController: UIViewController {
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    
    //timer설정관련
    var timer: Timer!
    let timeSelector: Selector = #selector(updateTime)
    var mapView: NMFMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager = CLLocationManager()
        locationManager.delegate = self
        getLocationUsagePermission()
        
        //지도객체1 NMFMapView
        let frame = CGRect(x:0, y:120, width:self.view.frame.size.width, height:self.view.frame.size.height-130)
        mapView = NMFMapView(frame: frame)
        //내부지도 보일 수 있게
        mapView.isIndoorMapEnabled = true
        //mapView.indoor
        view.addSubview(mapView)
        
        //좌표객체
//        let coord = NMGLatLng(lat: 37.5670135, lng: 126.9783740)
//        print("위도: \(coord.lat), 경도: \(coord.lng)")
        
        
        
        /*타이머 설정하기*/
        //timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: timeSelector, userInfo: nil, repeats: true)
    }
    @objc func updateTime() {
        if CLLocationManager.authorizationStatus().rawValue == 0 || CLLocationManager.authorizationStatus().rawValue == 1 ||
            CLLocationManager.authorizationStatus().rawValue == 2{
            print("not authorized")
        } else {
            let lat = currentLocation.coordinate.latitude
            let lng = currentLocation.coordinate.longitude
        
            print("위도 : \(lat), 경도 : \(lng)")
        }
    }

}
extension ViewController: CLLocationManagerDelegate {
    func getLocationUsagePermission() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .authorizedAlways, .authorizedWhenInUse:
            //authorizedAlways : 항상허용, authorizedWhenInUse : 사용할때만 허용
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                //위치 정보 받아오기 시작
                locationManager.startUpdatingLocation()
                
                print("GPS권한 설정됨. status : \(status.rawValue)")
                
            case .restricted, .notDetermined:
                print("GPS권한 설정되지 않았거나, 사용자의 위치서비스 제한 status : \(status.rawValue)")
                //한번 더 위치권한 창 띄우기
                getLocationUsagePermission()
            case .denied:
                print("GPS권한 요청 거부됨  status : \(status.rawValue)")
                //setLocationSetting()
            default:
                print("GPS:Default")
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        currentLocation = locations[locations.count-1]
        /*카메라 이동하기*/
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: currentLocation?.coordinate.latitude ?? 37.5670135, lng: currentLocation?.coordinate.longitude ?? 126.9783740))
        cameraUpdate.animation = .easeIn
        mapView.moveCamera(cameraUpdate)
        
        /*marker 찍기*/
        let marker = NMFMarker()
        marker.position = NMGLatLng(lat: currentLocation?.coordinate.latitude ?? 37.5670135, lng: currentLocation?.coordinate.longitude ?? 126.9783740)
        marker.mapView = mapView
    }
}


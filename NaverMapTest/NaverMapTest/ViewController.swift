//
//  ViewController.swift
//  NaverMapTest
//
//  Created by 박세라 on 2022/03/03.

import UIKit

import CoreLocation
import NMapsMap

import Alamofire
import SwiftyJSON

class ViewController: UIViewController, NMFMapViewTouchDelegate {
    
    @IBOutlet weak var mapView: NMFMapView!
    @IBOutlet weak var tfAddress: UITextField!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    
    //timer설정관련
    var timer: Timer!
    let timeSelector: Selector = #selector(updateTime)
    //var mapView: NMFMapView!
    
    //네이버 키 관련
    let infoDic = Bundle.main.infoDictionary!
    
//    lazy var NAVER_CLIENT_ID = infoDic["X-NCP-APIGW-API-KEY-ID"] as! String
//    lazy var NAVER_SECRET_KEY = infoDic["X-NCP-APIGW-API-KEY"] as!  String
    lazy var NAVER_CLIENT_ID = "***************"
    lazy var NAVER_SECRET_KEY = "**********"
    let NAVER_GEOCODE_URL = "https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query="
    let NAVER_LOCATION_URL = "https://openapi.naver.com/v1/search/local.json?query="
//    lazy var header1 = HTTPHeader(name: "X-NCP-APIGW-API-KEY-ID", value: NAVER_CLIENT_ID)
//    lazy var header2 = HTTPHeader(name: "X-NCP-APIGW-API-KEY", value: NAVER_SECRET_KEY)
    lazy var header1 = HTTPHeader(name: "X-Naver-Client-Id", value: NAVER_CLIENT_ID)
    lazy var header2 = HTTPHeader(name: "X-Naver-Client-Secret", value: NAVER_SECRET_KEY)
    lazy var headers = HTTPHeaders([header1, header2])
    var addressKey: String = "서울시 중구 퇴계로6길 3-6"
    lazy var encodeAddress = addressKey.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        
        getLocationUsagePermission()
        
        //지도객체1 NMFMapView
        let frame = CGRect(x:0, y:120, width:self.view.frame.size.width, height:self.view.frame.size.height-130)
        mapView = NMFMapView(frame: frame)
        //mapView.
        //내부지도 보일 수 있게
        mapView.isIndoorMapEnabled = true
        mapView.touchDelegate = self
        view.addSubview(mapView)
        
        var title = "미용실"
        lazy var encodeQuery = title.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        var query = encodeQuery! + "&display=5&start=1&sort=comment"
        print(query)
        urlParser(NAVER_LOCATION_URL, query, .get, headers)
        
    }
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        print("지도 터치됨", latlng.lat, latlng.lng, point)
        self.moveCameraAndMark(latlng.lat, latlng.lng)
    }
    
    //타이머 함수
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
    //입력창 외의 뷰 터치 시 키보드 내리기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //검색 버튼을 눌렀을 때
    @IBAction func btnSearch(_ sender: UIButton) {
        addressKey = String(tfAddress.text!)
        encodeAddress = addressKey.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        //setHeader()
    }
    //urlParser
    func urlParser(_ url: String, _ encodedAddress: String, _ method: HTTPMethod, _ headers: HTTPHeaders) {
        var requestURL = url + encodedAddress
        print(requestURL)
        //Alamofire로 request보내기
        AF.request(requestURL, method: method, headers: headers).validate()
                .responseJSON { response in
                    switch response.result {
                        case .success(let value as [String:Any]):
                            let json = JSON(value)
                            print(json)
                            let data = json["items"]
                            if data == []{
                                print("이곳 주소 다시 입력")
                                self.moveCameraAndMark(self.currentLocation?.coordinate.latitude ?? 37.5670135, self.currentLocation?.coordinate.longitude ?? 126.9783740)
                            } else {
                                /*address api*/
//                                let lat = data[0]["y"]
//                                let lon = data[0]["x"]
//                                print("이곳의","위도는",lat,"경도는",lon, type(of: lat))
//                                self.moveCameraAndMark(lat.doubleValue, lon.doubleValue)
                                
                                /*location api*/
                                let mapx = data[4]["mapx"]
                                let mapy = data[4]["mapy"]
                                print(mapx, mapy, type(of: mapx), type(of: mapy))
                                
                                
//                                let utmk = NMGUtmk(x: mapx.doubleValue, y: mapy.doubleValue)
                                let utmk = NMGUtmk(x: 544855, y: 287123)
                                let latLng = utmk.toLatLng()
                                print(latLng.lat, latLng.lng)
                                //self.moveCameraAndMark(latLng.lat, latLng.lng)
                            }
                        case .failure(let error):
                            //print(error.errorDescription ?? "")
                            print()
                        default :
                            //fatalError()
                            print()
                    }
                }
    }
    
    func moveCameraAndMark(_ latitude: Double, _ longitude: Double) {
        /*카메라 이동하기*/
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: latitude ?? 37.5670135, lng: longitude ?? 126.9783740))
        cameraUpdate.animation = .easeIn
        
        /*marker 설정 후 찍기*/
        let marker = NMFMarker()
        marker.position = NMGLatLng(lat: latitude ?? 37.5670135, lng: longitude ?? 126.9783740)
        marker.iconImage = NMF_MARKER_IMAGE_BLACK
        marker.iconTintColor = UIColor.systemBlue
        marker.width = CGFloat(NMF_MARKER_SIZE_AUTO)
        marker.height = CGFloat(NMF_MARKER_SIZE_AUTO)
        marker.captionText = "검색한 위치"
        marker.captionAligns = [NMFAlignType.top]
        
        mapView.moveCamera(cameraUpdate)
        marker.mapView = mapView
    }
}

// MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    func getLocationUsagePermission() {
        //백그라운드에서는 허용하지는 않는 경우
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
    }
}

// MARK: - UIViewController
extension UIViewController {
}


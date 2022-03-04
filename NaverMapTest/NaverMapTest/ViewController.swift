//
//  ViewController.swift
//  NaverMapTest
//
//  Created by 박세라 on 2022/03/03.
//

import UIKit
import NMapsMap

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let mapView = NMFMapView(frame: view.frame)
        view.addSubview(mapView)
    }


}


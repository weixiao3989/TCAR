//
//  mapVC.swift
//  TCAR
//
//  Created by david lin on 2017/10/24.
//  Copyright © 2017年 MUST. All rights reserved.
//

import UIKit
import MapKit

class mapVC: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 設定座標
        let taipei101 = CLLocationCoordinate2D(latitude: 25.033850, longitude: 121.564977)
        let airstation = CLLocationCoordinate2D(latitude: 25.068554, longitude: 121.552932)
        
        // 根據座標得到地標
        let pA = MKPlacemark(coordinate: taipei101, addressDictionary: nil)
        let pB = MKPlacemark(coordinate: airstation, addressDictionary: nil)
        
        // 根據地標建立地圖項目
        let miA = MKMapItem(placemark: pA)
        let miB = MKMapItem(placemark: pB)
        miA.name = "台北101"
        miB.name = "松山機場"
        
        // 將起迄點放到陣列中
        let routes = [miA, miB]
        
        // 設定為開車模式
        let options = [MKLaunchOptionsDirectionsModeKey:
            MKLaunchOptionsDirectionsModeDriving]
        
        // 開啟地圖開始導航
        MKMapItem.openMaps(with: routes, launchOptions: options)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  ViewController.swift
//  test_HealthKit
//
//  Created by 荒川陸 on 2016/09/17.
//  Copyright © 2016年 Riku Arakawa. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    var samplePoint: NSDate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        samplePoint = NSDate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /// HealthStoreから移動距離データ取得
    @IBAction func readHealthData(){
        let type = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!
        let healthStore = HKHealthStore()
        
        // データ抽出クエリ
        let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 0, sortDescriptors: nil) { (query, results, error) in
            if let error = error {
                print(error)
            }
            
            if let results = results as? [HKQuantitySample]{
                dispatch_async(dispatch_get_main_queue()){
                    print("データ読み出し")
                    for result in results where self.samplePoint!.compare(result.startDate) == NSComparisonResult.OrderedAscending {
                        print(result.quantity)
                        print(result.startDate)
                    }
                }
            }
        }
        
        //権限確認
        let authorizedStatus = healthStore.authorizationStatusForType(type)
        if authorizedStatus == .SharingAuthorized {
            healthStore.executeQuery(query)
        } else {
            healthStore.requestAuthorizationToShareTypes([type], readTypes: [type]) {
                success, error in
                guard error == nil else { return }
                
                if success {
                    healthStore.executeQuery(query)
                }
            }
        }
    }
    
}

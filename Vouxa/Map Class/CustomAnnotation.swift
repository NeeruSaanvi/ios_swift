//
//  CustomAnnotation.swift
//  Vouxa
//
//  Created by Piyush Agarwal on 1/9/17.
//  Copyright © 2017 Pinesucceed. All rights reserved.
//

import UIKit
import MapKit

class CustomAnnotation: NSObject, MKAnnotation {

    var coordinate: CLLocationCoordinate2D
//    var price: String!
//    var name: String!
//    var maleAge: String!
    var tag: Int!
    var pinDetails: NSDictionary!
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    
}

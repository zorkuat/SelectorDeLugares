//
//  Extensions.swift
//  SelectorDeLugares
//
//  Created by Tomás Álvarez on 27/7/18.
//  Copyright © 2018 Tomás Álvarez. All rights reserved.
//

import Foundation
import MapKit

extension CLLocationCoordinate2D{
    
    /// !!! ESTO SE ME ESTÁ DESCONTROLANDO
    func annotation(withTitile title:String?, subTitle: String?) -> Annotation{
        return Annotation(coordinate: self, title: title, subtitle: subTitle/*, id: 0*/)
    }
}

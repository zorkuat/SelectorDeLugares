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
    
    /// Crear una anotación como función extendida de una coordenada
    func annotation(withTitile title:String?, subTitle: String?) -> Annotation{
        return Annotation(coordinate: self, title: title, subtitle: subTitle)
    }
}

//
//  Annotation.swift
//  SelectorDeLugares
//
//  Created by Tomás Álvarez on 27/7/18.
//  Copyright © 2018 Tomás Álvarez. All rights reserved.
//

import Foundation
import MapKit

class Annotation: NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    //var id: Int
    
    init(coordinate: CLLocationCoordinate2D, title:String?, subtitle:String?/*, id: Int*/)
    {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        //self.id = id

        super.init()
    }
}

class AnnotationsList {
    var annotations : Array<Annotation> = []

    func carga_anotacion (anotacion: Annotation)
    {
        annotations.append(anotacion)
    }
}

class Whitebox {
    var annotations : Array<Annotation> = []
 
    let southOfSweden : Annotation = Annotation(coordinate: CLLocationCoordinate2D(latitude: 57.166096, longitude: 16.993009), title: "Löttorp", subtitle: "Centrum"/*, id: 1*/)
    
    let laFabrica : Annotation = Annotation(coordinate: CLLocationCoordinate2D(latitude: 40.45751, longitude: -3.693629), title: "La Fábrica", subtitle: "Espacio de Coworking"/*, id: 2*/)
    
    let canalIsabelII : Annotation = Annotation(coordinate: CLLocationCoordinate2D(latitude: 40.4392197, longitude: -3.7034533), title: "Canal de Isabel II", subtitle: "Gestión de red de aguas de Madrid"/*, id: 3*/)
    
    let archivoHistoricoNacional : Annotation = Annotation(coordinate: CLLocationCoordinate2D(latitude: 40.4411736, longitude: -3.689695), title: "Archivo Histórico Nacional", subtitle: "Aquí se archivan las historias nacionales"/*, id: 4*/)
    
    let centroABCSerrano : Annotation = Annotation(coordinate: CLLocationCoordinate2D(latitude: 40.4327582, longitude: -3.6902218), title: "ABC Serrano", subtitle: "Centro Comercial"/*, id: 5*/)
    
    let teatroMaravillas : Annotation = Annotation(coordinate: CLLocationCoordinate2D(latitude: 40.428676, longitude: -3.7042609), title: "Teatro Maravillas", subtitle: "Aquí actúa Jamming"/*, id: 6*/)

    init() {
        annotations.append(southOfSweden)
        annotations.append(laFabrica)
        annotations.append(canalIsabelII)
        annotations.append(archivoHistoricoNacional)
        annotations.append(centroABCSerrano)
        annotations.append(teatroMaravillas)
    }
}

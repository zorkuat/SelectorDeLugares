//
//  Annotation.swift
//  SelectorDeLugares
//
//  Created by Tomás Álvarez on 27/7/18.
//  Copyright © 2018 Tomás Álvarez. All rights reserved.
//

import Foundation
import MapKit

/// Clase Anotaciones.
/// Es una interfaz del protocolo MKAnnotation. Básicamente es como un protocolo al que hay
/// que definirle coordinate, title y subtitle para que encaje todo.
class Annotation: NSObject, MKAnnotation{
    // Variable del protocolo
    var coordinate: CLLocationCoordinate2D
    // Variable del protocolo
    var title: String?
    // Variable del protocolo
    var subtitle: String?
    
    // Más variables que le quiera yo meter
    // ****** //
    
    // INIT obligatorio. Lo básico es asignar valores a la estructura
    init(coordinate: CLLocationCoordinate2D, title:String?, subtitle:String?)
    {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle

        super.init()
    }
    
    // Más estructuras que quiera yo meterle
}

/// Lista de anotaciones

// En realidad sólo es una interfaz. Pero no quiero trabajar directamente con el array
// por si acaso esto acaba derivando en una estructura de datos.
// Así el código troncal es más limpio
class AnnotationsList {
    var annotations : Array<Annotation> = []

    func carga_anotacion (anotacion: Annotation)
    {
        annotations.append(anotacion)
    }
}

// *********************** //
// Clase para pruebas.
// Como todavía no domino la técnica de las pruebas unitarias me creo la caja aquí.
// Básicamente cargo seis coordenadas cualquiera en una lista. Sólo debería utilizarse para cargar datos en la base de datos. Así que podría ir fuera de este fichero.
class Whitebox {
    var annotations : Array<Annotation> = []
 
    let southOfSweden : Annotation = Annotation(coordinate: CLLocationCoordinate2D(latitude: 57.166096, longitude: 16.993009), title: "Löttorp", subtitle: "Centrum")
    
    let laFabrica : Annotation = Annotation(coordinate: CLLocationCoordinate2D(latitude: 40.45751, longitude: -3.693629), title: "La Fábrica", subtitle: "Espacio de Coworking")
    
    let canalIsabelII : Annotation = Annotation(coordinate: CLLocationCoordinate2D(latitude: 40.4392197, longitude: -3.7034533), title: "Canal de Isabel II", subtitle: "Gestión de red de aguas de Madrid")
    
    let archivoHistoricoNacional : Annotation = Annotation(coordinate: CLLocationCoordinate2D(latitude: 40.4411736, longitude: -3.689695), title: "Archivo Histórico Nacional", subtitle: "Aquí se archivan las historias nacionales")
    
    let centroABCSerrano : Annotation = Annotation(coordinate: CLLocationCoordinate2D(latitude: 40.4327582, longitude: -3.6902218), title: "ABC Serrano", subtitle: "Centro Comercial")
    
    let teatroMaravillas : Annotation = Annotation(coordinate: CLLocationCoordinate2D(latitude: 40.428676, longitude: -3.7042609), title: "Teatro Maravillas", subtitle: "Aquí actúa Jamming")

    init() {
        annotations.append(southOfSweden)
        annotations.append(laFabrica)
        annotations.append(canalIsabelII)
        annotations.append(archivoHistoricoNacional)
        annotations.append(centroABCSerrano)
        annotations.append(teatroMaravillas)
    }
    // ************* //
}

//
//  ViewController.swift
//  SelectorDeLugares
//
//  Created by Tomás Álvarez on 27/7/18.
//  Copyright © 2018 Tomás Álvarez. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

/// Clase principal
/// La clase está sobrecargada de funcionalidades (como picker views y eso). Lo suyo sería separar en clases
/// intermedias y dejar exclusivamente el View como Interfaz de entrada salida, tratando de respetar el keep It Simple
/// y delegando en clases puente las tareas específicas de tratamiento de datos.
/// PROTOCOLOS:
///     - UIViewController: Por defecto, porque es una clase de vista
///     - MKMapViewDelegate: Para el manejo de la clase mapa
///     - UIPickerViewDelegate: Para el manejo de la vista de selección de anotaciones
///     - UIPickerViewDataSource: Para la gestión de la entrada de datos.
///     - EditorDelegate: Manejo de las órdenes CRUD lanzadas desde la vista EditorAnotaciónViewController.

class MapaAnotacionesViewController: UIViewController, MKMapViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, EditorDelegate {

    /// Marcado de la clase app para acceso a los Gestores
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    /// Iniciaclización de las clases internas
    /// Interfaz con la clase de trabajo de anotaciones
    lazy var listaAnotaciones = self.appDelegate.listaAnotaciones
    /// Puerto de carga de coordenada de posición del GPS
    lazy var nuevaCoordenada : CLLocationCoordinate2D = (self.appDelegate.locationManager.location?.coordinate)!
    
    /// Fila seleccionada donde el mapa está centrado.
    var fila = 0
    
    /// OUTLETS del picker, toolbar auxiliar del picker, selector de texto y mapview
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var annotationsTextSelector: UITextField!
    @IBOutlet var annotationPickerView: UIPickerView!
    @IBOutlet var pickerViewToolbar: UIToolbar!
    
    
    /// Botones del menú del mapView
    // BOTON TRACKING
    var trackingButton: UIBarButtonItem{
        let button = MKUserTrackingButton(mapView: self.mapView)
        return UIBarButtonItem(customView: button)
    }
    
    // BOTON BRUJULA
    var compassButton: UIBarButtonItem{
        let button = MKCompassButton(mapView: self.mapView)
        button.compassVisibility = .visible
        return UIBarButtonItem(customView: button)
    }
    
    /// $$$$$
    /// FALTA LA GESTION DE CAMBIOS Y ERRORES.

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// COFING del mapView
        mapView.mapType = .mutedStandard
        mapView.showsCompass = false
        mapView.delegate = self
        
        /// Set elementos de mapa en el navigation toolbar de la vista
        navigationItem.rightBarButtonItem = trackingButton
        navigationItem.leftBarButtonItem = compassButton

        // Mostrando la localización del móvil.
        mapView.showsUserLocation = true
        
        if CLLocationManager.locationServicesEnabled()
        {
            /// Dar de alta marcadores. De momento no lo usamos, porque usaré pines para poderlo mover.
            /// Los marcadores pueden ser interesantes para mostrar los registros públicos de otros usuarios.
            //mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
            
            /// Añadir las anotaciones cargadas de la base de datos al mapa.
            if listaAnotaciones.annotations.count > 0
            {
                for i in 0...listaAnotaciones.annotations.count-1
                {
                    mapView.addAnnotation(listaAnotaciones.annotations[i])
                }
            }
            
            /// Configuración para centrar el mapa en la posición del GPS del usuario
            if self.appDelegate.locationManager.location != nil
            {
                let noLocation =  self.appDelegate.locationManager.location!.coordinate
                let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
                let viewLocation = MKCoordinateRegionMake(noLocation, span)
                /// Centramos el mapa
                mapView.setRegion(viewLocation, animated: false)
            }


        }

        /// Definimos el nombre del selector de texto
        annotationsTextSelector.text = "Tu ubicación"
        
        /// Configuramos el picker
        annotationPickerView.delegate = self
        annotationPickerView.translatesAutoresizingMaskIntoConstraints = false
        annotationsTextSelector.inputView = annotationPickerView
        annotationsTextSelector.inputAccessoryView = pickerViewToolbar
    }

    /// Recargamos los datos si volvemos a la pantalla.
    override func viewDidAppear(_ animated: Bool) {
        self.reloadInputViews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /////////////////////////////
    // MARK: - MapViewDelegate //
    /////////////////////////////
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        /// CÓDIGO ANTIGUO.
        /// LA diferencia está en que antes era un marcador con el que se veía la información sin
        /// pinchar en el pin. Por la naturaleza de lo que queremos, mejor ponemos el pin. Es más
        /// fluido y trascendente. Los markers se podrían usar para anotaciones públicas de otros.
        //guard let view = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier) as? MKPinAnnotationView else {return nil}
        //let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        //view.animatesWhenAdded = true
        //view.titleVisibility = .adaptive
        //view.subtitleVisibility = .adaptive
        //view.isDraggable = true
        //view.canShowCallout = true
        
        /// Si la anotación es la del usuario no ponemos pin. Ya muestra la animación de ubicación.
        if annotation is MKUserLocation  {
            return nil
        }
        
        /// Para anotaciones. Utilizamos el pin básico.
        let reuseId = "pin"
        var pav:MKPinAnnotationView?
        if (pav == nil)
        {
            /// Hacemos el pin arrastrable.
            pav = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pav?.isDraggable = true
            pav?.canShowCallout = true;
        }
        else
        {
            pav?.annotation = annotation;
        }
        
        return pav;
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        
        /// Si el pin se ha movido, al final de la operación:
        if (newState == MKAnnotationViewDragState.ending)
        {
            // 1. Cambiar las coordenadas de la anotación en la base de datos.
            // La anotación de la whitebox está cambiada (es la annotation registrada)
            // asi que, lo primero es filtrar por la anotación.
            
            let indexAnnotation = listaAnotaciones.annotations.index(where: {$0.hash == view.annotation!.hash})
            _ = appDelegate.gestorBBDD.actualizar_Anotacion(rowid: indexAnnotation!+1, anotacion: view.annotation!)
            //let droppedAt: CLLocationCoordinate2D = view.annotation!.coordinate;
            //print("dropped at \(droppedAt)")
        }
    }
    
    
    /////////////////////////////
    // MARK: - Picker Delegate //
    /////////////////////////////////////////////////////////////////////////////////////
    // Definición de los datos del picker, como los títulos de la lista de anotaciones //
    /////////////////////////////////////////////////////////////////////////////////////
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return listaAnotaciones.annotations.count+1
    }
    
    //////////////////////////////////
    // MARK: - Delegate Picker view //
    //////////////////////////////////
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0
        {
            return "Tu ubicación"
        }
        else
        {
            return listaAnotaciones.annotations[row-1].title
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        fila = row
        if row == 0
        {
            nuevaCoordenada = (self.appDelegate.locationManager.location?.coordinate)!
            return annotationsTextSelector.text = "Tu ubicación"
        }
        else
        {
            nuevaCoordenada =  listaAnotaciones.annotations[row-1].coordinate
            return annotationsTextSelector.text = listaAnotaciones.annotations[row-1].title
        }
    }
    
    /// Por si acaso, cuando volvemos del campo de texto selector, centramos.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let noLocation = nuevaCoordenada
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let viewLocation = MKCoordinateRegionMake(noLocation, span)
        
        mapView.setRegion(viewLocation, animated: true)
        textField.resignFirstResponder();
        
        return true
    }
    
    /// Centramos.
    @IBAction func botonDonePulsado(_ sender: Any) {
        
        let noLocation = nuevaCoordenada
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let viewLocation = MKCoordinateRegionMake(noLocation, span)
        
        mapView.setRegion(viewLocation, animated: true)
        annotationsTextSelector.resignFirstResponder()
    }

    /////////////////////////////////
    // MARK: - Gesture Recognition //
    /////////////////////////////////
    
    /// Acción del swipe.
    @IBAction func editar(_ sender: Any) {
        //print("Nos vamos a la pantalla de edición")
        performSegue(withIdentifier: "editar", sender: nil)
    }
    
    /// Acción de pulsado largo
    @IBAction func crearPuntoDeInteres(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began
        {
            let pixelPulsado = sender.location(in: self.mapView)
            let coordenadasPunto = self.mapView.convert(pixelPulsado, toCoordinateFrom: self.mapView)
            let anotacionNueva = coordenadasPunto.annotation(withTitile: "Título Nueva Anotación", subTitle: "Subtitulo Nueva Anotación")
            
            listaAnotaciones.annotations.append(anotacionNueva)
            self.mapView.addAnnotation(anotacionNueva)
            _ = self.appDelegate.gestorBBDD.insert_anotacion(id: listaAnotaciones.annotations.count,
                                                             lon: anotacionNueva.coordinate.longitude,
                                                             lat: anotacionNueva.coordinate.latitude,
                                                             tit: anotacionNueva.title!,
                                                             subt: anotacionNueva.subtitle!)
            
            performSegue(withIdentifier: "editar", sender: sender)
        }

    }
    
    ////////////////////////
    // MARK: - Navigation //
    ////////////////////////
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        // Enviamos la anotación seleccionada o una nueva si estamos en la del usuario.
        let anotacionEnviada : Annotation
        if fila != 0
        {
            anotacionEnviada = listaAnotaciones.annotations[fila-1]
        }
        else
        {
            /// Dos opciones. O está añadida ya, porque hemos hecho un pulsar largo o no está añadida porque hemos hecho swipe desde "tu ubicación"
            if sender is UILongPressGestureRecognizer
            {
                anotacionEnviada = listaAnotaciones.annotations[listaAnotaciones.annotations.count-1]
            }
            else
            {
                anotacionEnviada = (mapView.userLocation.location?.coordinate.annotation(withTitile: "Título Nueva Anotación", subTitle: "Subtitulo Nueva Anotación"))!
                
                listaAnotaciones.annotations.append(anotacionEnviada)
                self.mapView.addAnnotation(anotacionEnviada)
                _ = self.appDelegate.gestorBBDD.insert_anotacion(id: listaAnotaciones.annotations.count,
                                                                 lon: anotacionEnviada.coordinate.longitude,
                                                                 lat: anotacionEnviada.coordinate.latitude,
                                                                 tit: anotacionEnviada.title!,
                                                                 subt: anotacionEnviada.subtitle!)
            }
            
        }
        
        let destino = segue.destination as! EditarAnotacionViewController
        destino.anotacionEditando = anotacionEnviada
        destino.delegado = self
    }

    
    ////////////////////////////
    // MARK: EDITOR DELEGATE ///
    ////////////////////////////
    
    /// $$$ Pendiente. Guardamos nueva ubicación, almacenamos en base de datos.
    func guardar(_ anotacion: inout Annotation) {
        if fila == 0
        {
            listaAnotaciones.annotations[listaAnotaciones.annotations.count-1].title = anotacion.title
            listaAnotaciones.annotations[listaAnotaciones.annotations.count-1].subtitle = anotacion.subtitle
            
            _ = appDelegate.gestorBBDD.actualizar_Anotacion(rowid: listaAnotaciones.annotations.count, anotacion: anotacion)
        }
        else
        {
            listaAnotaciones.annotations[fila-1].title = anotacion.title
            listaAnotaciones.annotations[fila-1].subtitle = anotacion.subtitle
            _ = appDelegate.gestorBBDD.actualizar_Anotacion(rowid: fila, anotacion: anotacion)
        }
        
        annotationsTextSelector.text = anotacion.title
        self.reloadInputViews()
        
        return
    }
    
    /// Si la fila es la cero, no deberíamos borrar, porque no exisitiría la anotación (la fila cero es la del usuario)
    /// Si no:
    ///     - 1. Borramos la anotación de la base de datos.
    ///     - 2. Quitamos la anotación de la lista del mapview
    ///     - 3. Borramos la anotación de la estructura puerto
    ///     - 4. Cambiamos la ubicación a la posición del usuariol.
    func borrar() {
        if (fila != 0)
        {
            _ = appDelegate.gestorBBDD.borrar_rowid(id: fila, cuantos: listaAnotaciones.annotations.count)
            mapView.removeAnnotation(listaAnotaciones.annotations[fila-1])
            listaAnotaciones.annotations.remove(at: fila-1)
            
            /// Cambio de ubicación en el mapa
            nuevaCoordenada = (self.appDelegate.locationManager.location?.coordinate)!
            let noLocation = nuevaCoordenada
            let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
            let viewLocation = MKCoordinateRegionMake(noLocation, span)
            mapView.setRegion(viewLocation, animated: true)
            annotationsTextSelector.text = "Tu ubicación"
            fila = 0
        }
        return
    }
    
    /// Simplente, como si nada hubiese sucedido.
    func cancelar() {
        return
    }
}


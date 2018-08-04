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


class MapaAnotacionesViewController: UIViewController, MKMapViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, EditorDelegate {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    lazy var listaAnotaciones = self.appDelegate.listaAnotaciones
    lazy var nuevaCoordenada : CLLocationCoordinate2D = (self.appDelegate.locationManager.location?.coordinate)!
    
    var fila = 0
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var annotationsTextSelector: UITextField!
    @IBOutlet var annotationPickerView: UIPickerView!
    @IBOutlet var pickerViewToolbar: UIToolbar!
    
    
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
        
        mapView.mapType = .mutedStandard
        mapView.showsCompass = false
        mapView.delegate = self
        
        navigationItem.rightBarButtonItem = trackingButton
        navigationItem.leftBarButtonItem = compassButton

        // Mostrando la localización del móvil.
        mapView.showsUserLocation = true
        
        /// ???? AHORA MISMO NO SE PARA QUE SIRVE ESTO.
        //mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        for i in 0...listaAnotaciones.annotations.count-1
        {
            mapView.addAnnotation(listaAnotaciones.annotations[i])
        }
                
        let noLocation =  self.appDelegate.locationManager.location!.coordinate
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let viewLocation = MKCoordinateRegionMake(noLocation, span)
        
        mapView.setRegion(viewLocation, animated: false)
        
        annotationsTextSelector.text = "Tu ubicación"
        
        annotationPickerView.delegate = self
        annotationPickerView.translatesAutoresizingMaskIntoConstraints = false
        annotationsTextSelector.inputView = annotationPickerView
        annotationsTextSelector.inputAccessoryView = pickerViewToolbar
    }

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
        
        if annotation is MKUserLocation  {
            return nil
        }
        
        let reuseId = "pin"
        var pav:MKPinAnnotationView?
        if (pav == nil)
        {
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
    /////////////////////////////
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let noLocation = nuevaCoordenada
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let viewLocation = MKCoordinateRegionMake(noLocation, span)
        
        mapView.setRegion(viewLocation, animated: true)
        textField.resignFirstResponder();
        
        return true
    }
    
    @IBAction func botonDonePulsado(_ sender: Any) {
        
        let noLocation = nuevaCoordenada
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let viewLocation = MKCoordinateRegionMake(noLocation, span)
        
        mapView.setRegion(viewLocation, animated: true)
        annotationsTextSelector.resignFirstResponder()
    }

    @IBAction func editar(_ sender: Any) {
        print("Nos vamos a la pantalla de edición")
        performSegue(withIdentifier: "editar", sender: nil)
        
    }
    
    
    ////////////////////////
    // MARK: - Navigation //
    ////////////////////////
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        //
        let anotacionEnviada : Annotation
        if fila != 0
        {
            anotacionEnviada = listaAnotaciones.annotations[fila-1]
        }
        else
        {
            anotacionEnviada = Annotation(coordinate: (appDelegate.locationManager.location?.coordinate)!, title: nil, subtitle: nil)
        }
        let destino = segue.destination as! EditarAnotacionViewController
        destino.anotacionEditando = anotacionEnviada
        destino.delegado = self
    }
    
    ////////////////////////////
    // MARK: EDITOR DELEGATE ///
    ////////////////////////////
    
    func guardar(_ anotacion: inout Annotation) {
        return
    }
    
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
        }
        return
    }
    
    func cancelar() {
        return
    }
}


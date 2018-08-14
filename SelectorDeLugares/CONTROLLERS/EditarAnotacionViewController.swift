//
//  EditarAnotacion.swift
//  SelectorDeLugares
//
//  Created by Tomás Álvarez on 2/8/18.
//  Copyright © 2018 Tomás Álvarez. All rights reserved.
//

import UIKit
import TagListView

class EditarAnotacionViewController: UIViewController, UITextFieldDelegate {

    var anotacionEditando : Annotation?
    /// Copia de la información original para que se pueda cancelar fácil.
    var anotacionDeTrabajo : Annotation?
    
    /// Declaración de delegado de CRUD
    weak var delegado : EditorDelegate?
    
    @IBOutlet weak var tituloTextField: UITextField!
    @IBOutlet weak var subtituloTextField: UITextField!
    
    @IBOutlet weak var tagSystem: TagListView!
    
    var tagsDePrueba = ["Contenido Público", "Edificio Público", "Aquí se cogen buenas setas", "Aquí no se cogen buenas setas"]
    override func viewDidLoad() {
        super.viewDidLoad()

        anotacionDeTrabajo = Annotation(coordinate: (anotacionEditando?.coordinate)!, title: anotacionEditando?.title, subtitle: anotacionEditando?.subtitle)
    
        tagSystem.addTags(tagsDePrueba)
        
        ////////////////////////////
        // CONFIGURACIÓN DE VISTA //
        ////////////////////////////
        // print("Estamos editando la anotación \(String(describing: anotacionEditando?.title))")
        // Do any additional setup after loading the view.
        
        /// Botón funcional: BORRAR DE LA LISTA: Icono de papelera
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(borrar))
        
        /// Botón funcional: GUARDAR EN LA LISTA: 'Guardad'
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(guardar))
        self.navigationItem.rightBarButtonItems?.append(saveButton)
        
        tituloTextField.text = anotacionDeTrabajo?.title!
        subtituloTextField.text = anotacionDeTrabajo?.subtitle!
        
        tituloTextField.delegate = self
        subtituloTextField.delegate = self
        
        /////////////////////////////////////////
        // $$$ Cargar información de anotación //
        /////////////////////////////////////////
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func borrar()
    {
        //print("Borrar de la lista")
        delegado?.borrar()
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func guardar()
    {
        anotacionDeTrabajo?.title = tituloTextField.text
        anotacionDeTrabajo?.subtitle = subtituloTextField.text
        
        delegado?.guardar(&anotacionDeTrabajo!)
        self.navigationController?.popViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    /// CREO QUE EMPIEZO A ENTEDER PORQUÉ ESTE PATRON DEBERÍA ESTAR FUERA DE ESTO, Y PORQUÉ ESTÁ DENTRO.
    // MARK: - Text field delegate
    /*func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == tituloTextField
        {
            anotacionDeTrabajo?.title = textField.text
        }
        else if textField == subtituloTextField
        {
            anotacionDeTrabajo?.subtitle = textField.text
        }
        else
        {
            return
        }
        return
    }*/

}

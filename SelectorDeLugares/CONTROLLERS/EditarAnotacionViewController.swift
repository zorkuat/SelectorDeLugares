//
//  EditarAnotacion.swift
//  SelectorDeLugares
//
//  Created by Tomás Álvarez on 2/8/18.
//  Copyright © 2018 Tomás Álvarez. All rights reserved.
//

import UIKit

class EditarAnotacionViewController: UIViewController {

    var anotacionEditando : Annotation?
    /// Declaración de delegado de CRUD
    weak var delegado : EditorDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Estamos editando la anotación \(String(describing: anotacionEditando?.title))")
        // Do any additional setup after loading the view.
        
        /// Botón funcional: BORRAR DE LA LISTA: Icono de papelera
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(borrar))
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(guardar))
        
        self.navigationItem.rightBarButtonItems?.append(saveButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func borrar()
    {
        print("Borrar de la lista")
        delegado?.borrar()
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func guardar()
    {
        print("Guardar en la lista")
        
        //delegado?.borrarMed()
        //self.navigationController?.popViewController(animated: true)
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

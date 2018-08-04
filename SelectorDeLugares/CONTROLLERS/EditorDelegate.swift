//
//  EditorDelegate.swift
//  SelectorDeLugares
//
//  Created by Tomás Álvarez on 4/8/18.
//  Copyright © 2018 Tomás Álvarez. All rights reserved.
//

import Foundation
import UIKit

protocol EditorDelegate : class {
    
    func guardar(_ anotacion : inout Annotation);
    func borrar();
    func cancelar();
}

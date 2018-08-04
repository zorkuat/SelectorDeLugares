//
//  GestorBBDD.swift
//  SelectorDeLugares
//
//  Created by Tomás Álvarez on 2/8/18.
//  Copyright © 2018 Tomás Álvarez. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
import UIKit
import SQLite


class GestorBBDD {
    
    // Dirección de la base de datos
    private let path : String
    
    // Conexión con la base
    private var db : Connection? = nil
    
    // Interfaces datos/bbdd
    
    // MARK : - TABLAS DE BBDD
    ////////////
    // TABLAS //
    ////////////
    private let anotaciones = Table("Anotaciones")
    
    // MARK : - COLUMNAS POR TABLA
    //////////////
    // COLUMNAS //
    //////////////
    // ANOTACIONES
    private let id_anotacion = Expression<Int64>("Id")
    private let longitud = Expression<Float64>("Longitud")
    private let latitud = Expression<Float64>("Latitud")
    private let titulo = Expression<String>("Titulo")
    private let subtitulo = Expression<String>("Subtitulo")
    private let etiquetas = Expression<String?>("Etiquetas")
    
    // MARK: - INIT -> Creación y/o conexión con las tablas
    init()
    {
        path = NSSearchPathForDirectoriesInDomains(
            .libraryDirectory, .userDomainMask, true
            ).first!
        
        do {
            self.db = try Connection("\(path)/db.sqlite3")
        }
        catch
        {
            print("Error al abrir la base de datos")
        }
    }
    
    func setup_BBDD()
    {
        // CREAR O ABRIR LA BASE DE DATOS, TABLA A TABLA
        // MARK: - Creación tabla ANOTACIONES
        ///////////////////
        /// ANOTACIONES ///
        ///////////////////
        do{
            try db!.run(anotaciones.create { t in
                t.column(id_anotacion, primaryKey: true)
                t.column(longitud, defaultValue: 0.0)
                t.column(latitud, defaultValue: 0.0)
                t.column(titulo, defaultValue: "Titulo")
                t.column(subtitulo, defaultValue: "Subtitulo")
                t.column(etiquetas)
            })
        } catch {
            print("Tabla ya creada")
        }
    }
    
    // MARK: - FUNCIONES DE TABLA 'ANOTACIONES'
    func insert_anotacion(id: Int, lon: Double, lat: Double, tit: String, subt: String) -> Int
    {
        let inserccion = anotaciones.insert(id_anotacion <- Int64(id),
                                            longitud <- Float64(lon),
                                            latitud <- Float64(lat),
                                            titulo <- tit,
                                            subtitulo <- subt)
        do { _ = try db!.run(inserccion) }
        catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print("constraint failed: \(message), in \(String(describing: statement))")}
        catch { print("Error al insertar configuración")}
        return 0
    }
    
    func borrar_rowid (id: Int, cuantos: Int) -> Int
    {
        
        let fila = anotaciones.filter(id_anotacion == Int64(id))
        do { try db!.run(fila.delete()) }
        
        catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print("constraint failed: \(message), in \(String(describing: statement))")}
        catch { print("Error al obtener toda la tabla")}
        
        if (id < cuantos)
        {
            for i in (id+1)...cuantos
            {
                let fila_post = anotaciones.filter(id_anotacion == Int64(i))
                do {try db!.run(fila_post.update(id_anotacion <- Int64(i-1)))}
                catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
                    print("constraint failed: \(message), in \(String(describing: statement))")}
                catch { print("Error al actualizar la tabla")}
            }
        }
        
        return 0
    }
    
    func actualizar_Anotacion(rowid: Int, anotacion:MKAnnotation) -> Int
    {
            // SELECT * FROM "ANOTACIONES"
        let update_anotacion = anotaciones.filter(id_anotacion == Int64(rowid))
            let updating = update_anotacion.update(longitud <-  Float64(anotacion.coordinate.longitude),
                                                   latitud <- Float64(anotacion.coordinate.latitude),
                                                   titulo <- anotacion.title!!,
                                                   subtitulo <- anotacion.subtitle!!)
            do
            {
                _ = try db?.run(updating)
                return 0
            }
            catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT
            {
                print("constraint failed: \(message), in \(String(describing: statement))")
                return -1
            }
            catch
            {
                print("Error al actualizar base de datos")
                return -1
            }
    }
    
    func init_mock(whitebox: Whitebox) -> Int
    {
        var result = 0
        for i in 0...whitebox.annotations.count-1
        {
           result = insert_anotacion(id: i+1,
                             lon: whitebox.annotations[i].coordinate.longitude,
                             lat: whitebox.annotations[i].coordinate.latitude,
                             tit: whitebox.annotations[i].title!,
                             subt: whitebox.annotations[i].subtitle!)
        }
        return result
    }
    
    func cargar_anotaciones(lista :  AnnotationsList)
    {
        do {
            // SELECT * FROM "ANOTACIONES"
            for anot in (try db?.prepare(anotaciones))! {
            
                //let id = anot[id_anotacion]
                let lon = anot[longitud]
                let lat = anot[latitud]
                let tit = anot[titulo]
                let subt = anot[subtitulo]
                //let etiq = anot[etiquetas]
            
                let anotacion = Annotation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon), title: tit, subtitle: subt/*, id: Int(id)*/)
            
                lista.carga_anotacion(anotacion: anotacion)
            }
        }
        catch {
            print("Error al cargar datos internos")
        }
    }
    
    /*func recuperar_anotacion(id: Int) -> Annotation?
    {
        var anotacion : Annotation?
        
        
        return anotacion
    }*/
}

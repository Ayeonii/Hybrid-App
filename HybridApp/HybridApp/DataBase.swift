//
//  DataBase.swift
//  HybridApp
//
//  Created by 이아연 on 2020/05/29.
//  Copyright © 2020 Ayeon. All rights reserved.
//

import UIKit
import SQLite3

class DataBase: NSObject {

    var db: OpaquePointer? = nil
    
    func openDataBase() {
       
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("TestDB.sqlite")
        
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK {
            print("Fail to Open DataBase")
        }
        
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS VisitLogs (id INTEGER PRIMARY KEY AUTOINCREMENT, URL TEXT, Date DOUBLE)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
    
    }
    
    func createVisitURL (url : URL, date : Date){
        var insertStatement : OpaquePointer? = nil
        let insertStatementString = "INSERT INTO VisitLogs (URL, Date) VALUES (?, ?);"
        let urlString = url.absoluteString
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let now = df.string(from: Date())
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement,nil)
            == SQLITE_OK{
            if sqlite3_bind_text(insertStatement, 1, urlString, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print(errmsg)
            }
            
            if sqlite3_bind_text(insertStatement, 2,now, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print(errmsg)
            }
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE {
            print("Insert Success")
        }else {
            print("Fail to Insert")
        }
        
        sqlite3_finalize(insertStatement)
    }
    
    func readVisitURL () {
    
        let queryStatementString = "SELECT * FROM VisitLogs;"
        var queryStatement: OpaquePointer? = nil

        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = sqlite3_column_int(queryStatement, 0)
                guard let queryResultCol1 = sqlite3_column_text(queryStatement, 1) else { print ("Query result is nil"); return  }
                guard let queryResultCol2 = sqlite3_column_text(queryStatement, 2) else { print ("Query result is nil"); return  }

                let url = String(cString : queryResultCol1)
                let dateTime = String(cString : queryResultCol2)
                
                print("\(id) | \(url) | \(dateTime)")
            }
        } else {
            print("Fail to Read Table")
        }
        sqlite3_finalize(queryStatement)
    }
    
    func deleteVisitURL (id : Int) {
        let deleteStatementStirng = "DELETE FROM VisitLogs WHERE id = " + String(id)
        var deleteStatement: OpaquePointer? = nil

        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Deleted")
            } else {
                print("Delete Fail")
            }
        } else {
            print("Delete Fail")
        }
        sqlite3_finalize(deleteStatement)
    }

}

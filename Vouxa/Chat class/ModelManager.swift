//
//  ModelManager.swift
//  Vouxa
//
//  Created by Piyush Agarwal on 12/29/16.
//  Copyright © 2016 Pinesucceed. All rights reserved.
//

import UIKit


let sharedInstance = ModelManager()
class ModelManager: NSObject {


    var database: FMDatabase? = nil


    // This code is called at most once
    class func getInstance() -> ModelManager
    {
        if(sharedInstance.database == nil)
        {
            sharedInstance.database = FMDatabase(path: UtilityClass.getPath(fileName: "vouxa.sqlite"))
        }
        return sharedInstance
    }



    func getTotalMessageCount(dialogId: String) -> (Int)
    {

            sharedInstance.database!.open()

            let rs:  FMResultSet = sharedInstance.database!.executeQuery("select count(*) as Count from chatTable where dialogid='" + dialogId + "'", withArgumentsIn: [])
            if rs.next()
            {

                let count: Int =  (Int)(rs.int(forColumn: "Count"))
//                sharedInstance.database!.commit()
                sharedInstance.database!.close()
                return count
            }
            else
            {
//                sharedInstance.database!.commit()
                sharedInstance.database!.close()
                return 0
            }
    }



    func insertOrUpdateIntoDialogTable(dialogObjects: [QBChatDialog]) {

        let shared = ModelManager.getInstance()

        shared.database!.open()

        //        let selectQuery
        //or replace
        let insertSQLStatment = "insert INTO DialogTable ('dialogId', 'dateTime', 'dialogInstance') VALUES (?, ?, ?)"

        let updateSQLStatment = "update DialogTable Set dialogInstance=? ,dateTime=? where dialogId=?"

        shared.database!.beginTransaction()

        for dialog in dialogObjects
        {
            
            let data : Data = NSKeyedArchiver.archivedData(withRootObject: dialog)
            
            
//            NSData *dataFromArray = [NSKeyedArchiver archivedDataWithRootObject:message];
            
            let isInsert = shared.database?.executeUpdate(insertSQLStatment, withArgumentsIn: [dialog.id!, dialog.updatedAt!, data])

            if(isInsert == false)
            {
                let isUpdate = shared.database?.executeUpdate(updateSQLStatment, withArgumentsIn: [ data, dialog.updatedAt!, dialog.id!])

                print(isUpdate!)
            }

        }

        shared.database!.commit()
        shared.database!.close()


    }


    func getDialogs() -> ([QBChatDialog])   {
        let shared = ModelManager.getInstance()

        shared.database!.open()

        let selectQuery = "Select * from DialogTable ORDER BY date(dateTime) DESC"

        let resultSet : FMResultSet! = shared.database?.executeQuery(selectQuery, withArgumentsIn: nil)

        var dialogsArray = [QBChatDialog]()
        
        
        if (resultSet != nil) {
            while resultSet.next() {
                
                
                let dialog: QBChatDialog = NSKeyedUnarchiver.unarchiveObject(with: resultSet.object(forColumnName: "dialogInstance") as! Data) as! QBChatDialog
                
                
                
//                [NSKeyedUnarchiver unarchiveObjectWithData:myData];
                
                dialogsArray.append(dialog)
//                dilaogsArray.add(resultSet.object(forColumnName: "dialogInstance"))
            }
        }


//        shared.database!.commit()
        shared.database!.close()
        //(forColumn: "dialogInstance")
        return dialogsArray
        
    }
    
    
    
    
    func insertIntoChatTable(dialogObjects: [QBChatMessage]) {
        
        let shared = ModelManager.getInstance()
        
        shared.database!.open()
        
        //        let selectQuery
        //or replace
        let insertSQLStatment = "insert INTO chatTable ('dialogid', 'dateTime', 'message') VALUES (?, ?, ?)"
        
        shared.database!.beginTransaction()
        
        for message in dialogObjects
        {
            
            let data : Data = NSKeyedArchiver.archivedData(withRootObject: message)
            
            
            //            NSData *dataFromArray = [NSKeyedArchiver archivedDataWithRootObject:message];
            
            let isInsert = shared.database?.executeUpdate(insertSQLStatment, withArgumentsIn: [message.dialogID!, message.dateSent!, data])
            
            if(isInsert == false)
            {
                break
            }
            
        }
        
        shared.database!.commit()
        shared.database!.close()
    }
    
    
    
    
    func getChatMessages(dialogId: String, count: Int) -> ([QBChatMessage])   {
        
        let shared = ModelManager.getInstance()
        
        shared.database!.open()

         shared.database!.beginTransaction()

//        let selectQuery = "Select * from chatTable "

        var selectQuery : String
        if(count == -1)
        {
            selectQuery = "Select * from chatTable where dialogid='" + dialogId + "' ORDER BY date(dateTime) ASC "
        }
        else
        {
//            selectQuery = "Select * from chatTable where dialogid='" + dialogId + "' ORDER BY date(dateTime) DESC LIMIT 50 OFFSET \(count)"
            
            selectQuery = "Select * from (Select * from chatTable where dialogid='" + dialogId + "' ORDER BY date(dateTime) DESC LIMIT 50 OFFSET \(count))tmp ORDER BY date(dateTime) ASC"
            
        }

        let resultSet : FMResultSet! = shared.database?.executeQuery(selectQuery, withArgumentsIn: nil)
        
        var messagesArray = [QBChatMessage]()
        
        
        if (resultSet != nil) {
            while resultSet.next() {
                
                
                let message: QBChatMessage = NSKeyedUnarchiver.unarchiveObject(with: resultSet.object(forColumnName: "message") as! Data) as! QBChatMessage

                messagesArray.append(message)
                
            }
        }
        
//        shared.database!.commit()
        shared.database!.close()
        //(forColumn: "dialogInstance")
        return messagesArray
        
    }
    
    func updateDialog(dialog: QBChatDialog) -> (Bool)
    {
         let shared = ModelManager.getInstance()
        shared.database!.open()
        
        shared.database!.beginTransaction()
        
        //        let selectQuery = "Select * from chatTable "
        let updateSQLStatment = "update DialogTable Set dialogInstance=? ,dateTime=? where dialogId=?"
        
        let data : Data = NSKeyedArchiver.archivedData(withRootObject: dialog)
        
        let isUpdate = shared.database?.executeUpdate(updateSQLStatment, withArgumentsIn: [ data, dialog.updatedAt!, dialog.id!])
        
        print(isUpdate!)
        
        shared.database!.commit()
        shared.database!.close()
        
        return isUpdate!
    }
    
    
    func deleteAllData()
    {
        let shared = ModelManager.getInstance()

        shared.database!.open()

        shared.database!.beginTransaction()

        //        let selectQuery = "Select * from chatTable "
        var deleteQuery = "DELETE  from chatTable"

        var isDelete = shared.database!.executeUpdate(deleteQuery, withArgumentsIn: nil)

        print("\(isDelete) == chat delete")

         deleteQuery = "DELETE  from DialogTable"
        isDelete = shared.database!.executeUpdate(deleteQuery, withArgumentsIn: nil)

        print("\(isDelete) == Dialog Delete")
        
        shared.database!.commit()
        shared.database!.close()

    }
}

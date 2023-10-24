//
//  DataController.swift
//  IssueTracker
//
//  Created by Joel Storr on 24.10.23.
//

import CoreData


class DataController: ObservableObject{
    let container: NSPersistentCloudKitContainer
    
    static var preview: DataController = {
        let dataConroller = DataController(inMemory: true)
        dataConroller.createSampleData()
        return dataConroller
    }()
    
    init(inMemory: Bool = false){
        container = NSPersistentCloudKitContainer(name: "Main")
        
        
        if inMemory{
            container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        }
        container.loadPersistentStores { storeDescription, error in
            if let error{
                fatalError("Fatel error loading store: \(error.localizedDescription)")
            }
        }
    }
    
    func createSampleData(){
        let viewContext = container.viewContext
        
        for i in 1...5{
            let tag = Tag(context: viewContext)
            tag.id = UUID()
            tag.name = "Tag \(i)"
            
            for j in 1...10{
                let issue = Issue(context: viewContext)
                issue.title = "Issue \(i)-\(j)"
                issue.content = "Description goes here"
                issue.creationDate = .now
                issue.completed = Bool.random()
                issue.priority = Int16.random(in: 0...2)
                tag.addToIssues(issue)
            }
        }
        
        try? viewContext.save()
    }
    
    //Only saves when there are chnages in the view context
    func save(){
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }
    
    
    //Delete single element
    func delet(_ object: NSManagedObject){
        objectWillChange.send()
        container.viewContext.delete(object)
        save()
    }
    
    
    //Delete all sample data
    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>){
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs //Return the IDs of the elements that got deleted
        
        //Execute the Batch Delete request
        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult{
            //Returns the object IDs that were deleted
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            //Merge store into view context so both stay in sync
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
        }
    }
    
    func deleteAll(){
        let request1: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
        delete(request1)
        
        let request2: NSFetchRequest<NSFetchRequestResult> = Issue.fetchRequest()
        delete(request2)
        
        save()
    }
    
}


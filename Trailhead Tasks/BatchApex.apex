// To write a Batch Apex class,
//  your class must implement the Database.Batchable interface

    public class BatchClass implements Database.Batchable<sObject> {


        // 1-Start
        // Used to collect the records or objects to be passed to the interface method execute for processing.
        public Database.QueryLocator start(Database.BatchableContext BC) {
            return Database.getQueryLocator('SELECT Id, Name FROM Account');
        }

        // 2-Execute
        // Used to process the records or objects returned by the start method.
        public void execute(Database.BatchableContext BC, List<Account> scope) {
            for (Account account : scope) {
                account.Name = 'New Name';
                update account;
            }
        }

        // 3-Finish
        // Used to perform any necessary post-processing after the last batch of records or objects has been processed.
        public void finish(Database.BatchableContext BC) {
            System.debug('Batch is finished');
        }
        
    }

    // Invoking a Batch Class
BatchClass batchOfRecords = new BatchClass();
Id batchId = Database.executeBatch(batchOfRecords,100);

// Create an Apex class that implements the Database.Batchable interface to update all Lead records in the org with a specific LeadSource.
// Use a QueryLocator in the start method to collect all Lead records in the org
// Use a for loop in the execute method to update the LeadSource field for each Lead record
// Use the System.debug method in the finish method to display a message when the batch is finished

public class LeadProcessor implements Database.Batchable<sObject> {
    global Integer count = 0;


    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id, LeadSource FROM Lead');
    }

    public void execute(Database.BatchableContext BC, List<Lead> scope) {
        List<lead> leadList = new List<lead>();

        for (Lead lead : scope) {
            lead.LeadSource = 'Dreamforce';
            leadList.add(lead);
            count +=1;
            
        }
        update lead;
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('Batch is finished with ' + count + ' records updated');
    }
}


@isTest
public class LeadProcessorTest{

    @isTest
    public static void testLeadRecord(){
        List<lead>leadList = new List<lead>();


        for(Integer el =0; el<100; el++){
            lead leadRecord = new lead();
            leadRecord.lastName = 'Name' + el;
            leadRecord.company = 'Company';
            leadList.add(leadRecord);
        }
        insert leadList;
        Test.startTest();
        LeadProcessor leadProcessor = new LeadProcessor();
        Id batchId = Database.executeBatch(leadProcessor,100);
        Test.stopTest();
        System.assertEquals(100,leadProcessor.count);
    }
}
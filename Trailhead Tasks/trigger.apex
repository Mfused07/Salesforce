trigger ExampleTrigger on Contact (after insert, after delete) {
    if (Trigger.isInsert) {
        Integer recordCount = Trigger.New.size();
        // Call a utility method from another class
        EmailManager.sendMail('Your email address', 'Trailhead Trigger Tutorial', 
                    recordCount + ' contact(s) were inserted.');
    }
    else if (Trigger.isDelete) {
        // Process after delete
    }
}

Contact c = new Contact(LastName='Test Contact');
insert c;

// Prevent the deletion of accounts if they have related opportunities.
trigger AccountDeletion on Account (before delete) {
   
    // Prevent the deletion of accounts if they have related opportunities.
    for (Account a : [SELECT Id FROM Account
                     WHERE Id IN (SELECT AccountId FROM Opportunity) AND
                     Id IN :Trigger.old]) {
        Trigger.oldMap.get(a.Id).addError(
            'Cannot delete account with related opportunities.');
    }
    
}







//Create an Apex trigger that sets an account’s Shipping Postal Code to match the Billing Postal Code if the Match Billing Address option is selected. Fire the trigger before inserting an account or updating an account.
trigger AccountAddressTrigger on Account (before insert, before update) {
List<Account> acclst = new List<Account>();

  for(account a:trigger.new){
    if(a.Match_Billing_Address__c == true ){
    a.ShippingPostalCode=a.BillingPostalCode;
        
    }

}
}


//bad practice
trigger MileageTrigger on Mileage__c (before insert, before update) {
    for (Mileage__c m : Trigger.new) {
        User u = [SELECT Id FROM User WHERE mileageid__c = m.id];
    }
}

//Best Pracitce 
Trigger MileageTrigger on Mileage__c (before insert, before update) {
    Set<ID> ids = Trigger.newMap.keysSet();
    List<User> c = [SELECT Id FROM User WHERE mileageid__c in :ids];
}



// 

trigger SoqlTriggerBulk on Account(after update) {  
    // Perform SOQL query once.    
    // Get the related opportunities for the accounts in this trigger.
    List<Opportunity> relatedOpps = [SELECT Id,Name,CloseDate FROM Opportunity
        WHERE AccountId IN :Trigger.New];
  
    // Iterate over the related opportunities    
    for(Opportunity opp : relatedOpps) { 
        // Do some other processing
    }
}











// perform DML in bulk efficiently with only one DML call on a list of opportunities
trigger DmlTriggerBulk on Account(after update) {   
    // Get the related opportunities for the accounts in this trigger.        
    List<Opportunity> relatedOpps = [SELECT Id,Name,Probability FROM Opportunity
        WHERE AccountId IN :Trigger.New];
          
    List<Opportunity> oppsToUpdate = new List<Opportunity>();

    // Iterate over the related opportunities
    for(Opportunity opp : relatedOpps) {      
        // Update the description when probability is greater 
        // than 50% but less than 100% 
        if ((opp.Probability >= 50) && (opp.Probability < 100)) {
            opp.Description = 'New description for opportunity.';
            oppsToUpdate.add(opp);
        }
    }
    
    // Perform DML on a collection
    update oppsToUpdate;
}

// no idea
trigger AddRelatedRecord on Account(after insert, after update) {
    
    List<Opportunity> oppList = new List<Opportunity>();
    
    // Add an opportunity for each account if it doesn't already have one.
    // Iterate over accounts that are in this trigger but that don't have opportunities.
    for (Account accountRecord : [SELECT Id,Name FROM Account
                     WHERE Id IN :Trigger.New AND
                     Id NOT IN (SELECT AccountId FROM Opportunity)]) {
        // Add a default opportunity for this account

        // Opportunity o = new Opportunity(Name = a.Name + ' Opportunity',
        //                                 StageName='Prospecting',
        //                                 CloseDate=System.today().addMonths(1),
        //                                 AccountId=a.Id);
        // oppList.add(o);

        oppList.add(new Opportunity(
            Name = accountRecord.Name + ' Opportunity',
            StageName='Prospecting',
            CloseDate=System.today().addMonths(1),
            AccountId=accountRecord.Id
        )); 

    }
    
    if (oppList.size() > 0) {
        insert oppList;
    }
}

// create



// Create a bulkified Apex trigger
trigger ClosedOpportunityTrigger on Opportunity (after insert, after update) {
    List<Task> taskList = new List<Task>();

    for(Opportunity o:trigger.new){
        if(o.StageName == 'Closed Won'){
            Task t = new Task();
            t.WhatId = o.Id;
            t.Subject = 'Follow Up Test Task'
            taskList.add(t);
        }
    }
    if(taskList.size() > 0){
         insert taskList;
    }
   
}
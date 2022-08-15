
// Future Method Syntax
public class SomeClass {
  @future
  public static void someFutureMethod(List<Id> recordIds) {
    List<Account> accounts = [Select Id, Name from Account Where Id IN :recordIds];
    // process account records to do awesome stuff
  }
}


// Sample Callout Code
//  methods for making the callout both synchronously and asynchronously where callouts are not permitted
public class SMSUtils {
    // Call async from triggers, etc, where callouts are not permitted.
    @future(callout=true)
    public static void sendSMSAsync(String fromNbr, String toNbr, String m) {
        String results = sendSMS(fromNbr, toNbr, m);
        System.debug(results);
    }
    // Call from controllers, etc, for immediate processing
    public static String sendSMS(String fromNbr, String toNbr, String m) {
        // Calling 'send' will result in a callout
        String results = SmsMessage.send(fromNbr, toNbr, m);
        // insert a record into a custom log object to track the status of the callout simply because logging is always fun to do
        insert new SMS_Log__c(to__c=toNbr, from__c=fromNbr, msg__c=results);
        return results;
    }
}


// Test Classes
// 1- enclose  test code between the startTest and stopTest test methods
// 2-system collects all asynchronous calls made after the startTest
// 3-When stopTest is executed, all collected asynchronous processes are then run synchronously.
//  You can then assert that the asynchronous call operated properly.

// Test code cannot actually send callouts to external systems
// you’ll have to ‘mock’ the callout for test coverage.

@isTest
public class SMSCalloutMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status":"success"}');
        res.setStatusCode(200);
        return res;
    }
}

public class AccountProcessor {
    @future(callout = true)
    public static void countContacts(List<id>  accountIds){
        List<Account> accounts = [SELECT Id,(SELECT Id FROM Contacts) FROM Account WHERE Id IN :accountIds];
    	
        for(Account accountRecord: accounts) {
            accountRecord.Number_Of_Contacts__c = accountRecord.Contacts.size();
        }
        update accounts;
    
    }
    

}

@isTest
public class AccountProcessorTest {
    @isTest
    static void countContactTest() {
        
        //Load Test Data
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i<100; i++) {
            accounts.add(new Account(Name = 'Test Account' +i));
        }
        insert accounts;
        
        List<Contact> contacts = new List<Contact>();
        List<Id> accountIds = new List<Id>();
        
        for(Account accountRecord: accounts) {
            contacts.add(new Contact(FirstName =accountRecord.Name,
                                    LastName ='TestContact',
                                    AccountId = accountRecord.Id));
            accountIds.add(accountRecord.Id);
                
        }
        insert contacts;

        Test.startTest();
        AccountProcessor.countContacts(accountIds);
        Test.stopTest();
        //check Result

        List<Account> updatedAccounts = [SELECT Id, Number_Of_Contacts__c FROM Account WHERE Id IN :accountIds];
        for(Account accountRecord: updatedAccounts) {
            System.assertEquals(accountRecord.Contacts.size(), accountRecord.Number_Of_Contacts__c);
        }
        
        
    }
}
public class UpdateParentAccount implements Queueable {
    private List<Account> accounts;
    private ID parent;
    public UpdateParentAccount(List<Account> records, ID id) {
        this.accounts = records;
        this.parent = id;
    }
    public void execute(QueueableContext context) {
        for (Account account : accounts) {
          account.parentId = parent;
          // perform other processing or callout
        }
        update accounts;
    }
}

// To add this class as a job on the queue
// find all accounts in ‘NY’
List<Account> accounts = [select id from account where billingstate = ‘NY’];
// find a specific parent account for all records
Id parentId = [select id from account where name = 'ACME Corp'][0].Id;
// instantiate a new instance of the Queueable class
UpdateParentAccount updateJob = new UpdateParentAccount(accounts, parentId);
// enqueue the job for processing
ID jobID = System.enqueueJob(updateJob);


// Testing Queueable Apex

@isTest
public class UpdateParentAccountTest {
    @testSetup
    static void setup() {
        List<Account> accounts = new List<Account>();
        // add a parent account
        accounts.add(new Account(name='Parent'));
        // add 100 child accounts
        for (Integer i = 0; i < 100; i++) {
            accounts.add(new Account(
                name='Test Account'+i
            ));
        }
        insert accounts;
    }
    static testmethod void testQueueable() {
        // query for test data to pass to queueable class
        Id parentId = [select id from account where name = 'Parent'][0].Id;
        List<Account> accounts = [select id, name from account where name like 'Test Account%'];
        // Create our Queueable instance
        UpdateParentAccount updater = new UpdateParentAccount(accounts, parentId);
        // startTest/stopTest block to force async processes to run
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest();
        // Validate the job ran. Check if record have correct parentId now
        System.assertEquals(100, [select count() from account where parentId = :parentId]);
    }
}


// Chaining Jobs

public class FirstJob implements Queueable {
    public void execute(QueueableContext context) {
        // Awesome processing logic here
        // Chain this job to next job by submitting the next job
        System.enqueueJob(new SecondJob());
    }
}

// Create a Queueable Apex class that inserts the same Contact for each Account for a specific state.
public class AddPrimaryContact implements Queueable{
    
    //  first argument a Contact sObject and a second argument as a string for the State abbreviation
    private Contact contact;
    private String state;
    public AddPrimaryContact(Contact contact, String state) {
        this.contact = contact;
        this.state = state;
    }

    public void execute(QueueableContext context) {
        List<Account> accounts =[SELECT Id, Name,
                                        (SELECT FirstName, LastName, Id From contacts)
                                        FROM Account where BillingState = :state Limit 200];

        List<Contact> primaryContacts = new List<Contact>();

        for (Account accountRecord : accounts) {
            Contact c = contact.clone();
            c.AccountId = accountRecord.Id;
            //Contact contact = new Contact(
                //FirstName = 'John',
                //LastName = 'Doe',
                //AccountId = accountRecord.Id
            //);
            
            //insert contact;
            
            primaryContacts.add(c);
            
        }
        if(primaryContacts.size() > 0) {
            insert primaryContacts;
        }
        
    }
}

@isTest
public class AddPrimaryContactTest {
    static testmethod void testQueueable(){
        List<Account> testAccounts = new List<Account>();
        for(Integer i = 0; i < 50; i++) {
            testAccounts.add(new Account(
                Name = 'Test Account' + i,
                BillingState = 'CA'
            ));
        }
        for(Integer j = 0;j<50;j++) {
            testAccounts.add(new Account(
                Name = 'Test Account' + j,
                BillingState = 'NY'
            ));
        }
        insert testAccounts;

        Contact testContact = new Contact(
            FirstName = 'mubi',
            LastName = 'yasin'
        );

        AddPrimaryContact addPrimaryContact = new AddPrimaryContact(testContact, 'CA');

        Test.startTest();
        System.enqueueJob(addPrimaryContact);
        Test.stopTest();

        System.assertEquals(50, [SELECT count() FROM Contact WHERE accountId in (SELECT Id FROM Account WHERE BillingState = 'CA')]);
    }
}
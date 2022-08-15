// Manipulate Records with DML

// Create the account sObject -----------------------------

Account acc = new Account(Name='Acme', Phone='555-555-5555', 
    NumberOfEmployees=100);

// Insert the account record using DML
insert acc;


// The following DML statements are available.---------------------------

// insert

// update

// upsert- 

// delete

// undelete

// merge- 



// ID Field Auto-Assigned to New Records---------------------------

// This example shows how to get the ID on the sObject that corresponds to the inserted account.

// Create the account sObject
Account acc = new Account(Name='Acme', Phone='555-555-5555', 
    NumberOfEmployees=100);

// Insert the account record using DML
insert acc;

// Get the ID of the inserted record
ID accId = acc.Id;
// Display the ID
system.debug('Account ID: ' + accId);
// DEBUG|ID = 001D000000JmKkeIAF


// Bulk DML-------------------------------------------------------
//  inserts contacts in bulk by inserting a list of contacts in one call. The sample then updates those contacts in bulk too.


// Create a list of contacts
List<Contact> contacts = new List<Contact>()
{
    new Contact(FirstName='Joe',LastName='Smith',Department='Finance'),
    new Contact(FirstName='Kathy',LastName='Smith',Department='Technology'),
    new Contact(FirstName='Caroline',LastName='Roth',Department='Finance'),
    new Contact(FirstName='Kim',LastName='Shain',Department='Education')
}

// Bulk insert all contacts with one DML call
insert contacts;

// List to hold new contacts to update

List<Contact> contactsToUpdate = new List<Contact>();

for(Contact c : contacts){
    if(c.Department == 'Finance'){
        c.Title = 'Finacial analyst';
        contactsToUpdate.add(c);
    }
}

// Bulk update all contacts with one DML call
update contactsToUpdate;


List<Contact> contacts = new List<Contact>()
{
    new Contact(FirstName='Joe',LastName='Smith',Department='Finance'),
    new Contact(FirstName='Kathy',LastName='Smith',Department='Technology'),
    new Contact(FirstName='Caroline',LastName='Roth',Department='Finance'),
    new Contact(FirstName='Kim',LastName='Shain',Department='Education')
}



insert contacts;
contacts[0].FirstName










// Upsert Syntax--------------------------------------------

// upsert sObject | sObject[]

// upsert sObject | sObject[] field

// The optional field is a field token. For example, to specify the MyExternalID field, the statement is:
upsert sObjectList Account.Fields.MyExternalId;

// Upsert uses the sObject record's primary key (the ID), an idLookup field, or an external ID field to determine whether it should create a new record or update an existing one:

// If the key is not matched, a new object record is created.
// If the key is matched once, the existing object record is updated.
// If the key is matched multiple times, an error is generated and the object record is neither inserted or updated.

Contact mubi = new Contact(FirstName='mubi',
                         LastName='yasir',
                         Email='mubi@gmail.com',
                         Description='Contact of the day');
insert mubi;
// 1. Upsert using an idLookup field
// Create a second sObject variable.
// This variable doesn’t have any ID set.
Contact mubi2 = new Contact(FirstName='mubi',
                         LastName='yasir',',  
                         Email='mubi@example.com',
                         Description='Prefers to be contacted by email.');
// Upsert the contact by using the idLookup field for matching.
upsert mubi2 Contact.fields.Email;
// Verify that the contact has been updated
System.assertEquals('Prefers to be contacted by email.',
                   [SELECT Description FROM Contact WHERE Id=:mubi.Id].Description);





// Delete records--------------------------------------------------

Contact[] contactsDel = [SELECT Id FROM Contact WHERE LastName='Smith']; 
delete contactsDel;


// DML Statement Exceptions-----------------------
try {
    // This causes an exception because 
    //   the required Name field is not provided.
    Account acct = new Account();
    // Insert the account 
    insert acct;
} catch (DmlException e) {
    System.debug('A DML exception has occurred: ' +
                e.getMessage());
}


// Database Methods------------------------------

// Database.insert() -> Database.insert(recordList, false);
// Database.update()
// Database.upsert()
// Database.delete()
// Database.undelete()
// Database.merge()

//return  objects containing success or failure information for each record
Database.SaveResult[] results = Database.insert(recordList, false);
// By default, the allOrNone parameter is true, which means that if any record fails, all records fail.


// The following two statements are equivalent to the insert recordList; statement.
Database.insert(recordList);
//and
Database.insert(recordList,true);



// Example: Insert Records with Partial Success----------------
// Create a list of contacts
List<Contact> conList = new List<Contact> {
        new Contact(FirstName='Joe',LastName='Smith',Department='Finance'),
        new Contact(FirstName='Kathy',LastName='Smith',Department='Technology'),
        new Contact(FirstName='Caroline',LastName='Roth',Department='Finance'),
        new Contact()};


// Bulk insert all contacts with one DML call
Database.SaveResult[] srList = Database.insert(conList, false);


// Iterate through each returned result
for (Database.SaveResult sr : srList) {
    if (sr.isSuccess()) {
        // Operation was successful, so get the ID of the record that was processed
        System.debug('Successfully inserted contact. Contact ID: ' + sr.getId());
    } else {
        // Operation failed, so get all errors
        for(Database.Error err : sr.getErrors()) {
            System.debug('The following error has occurred.');
            System.debug(err.getStatusCode() + ': ' + err.getMessage());
            System.debug('Contact fields that affected this error: ' + err.getFields());
	 }
    }
}

// his example shows how to add a contact to an account--------
//  (the related record) by setting the AccountId field on the
//   contact. Contact and Account are linked through a 
//   lookup relationship.
Account acct = new Account(Name='SFDC Account');
insert acct;
// Once the account is inserted, the sObject will be 
// populated with an ID.
// Get this ID.
ID acctID = acct.ID;
// Add a contact to this account.
Contact mario = new Contact(
    FirstName='Mario',
    LastName='Ruiz',
    Phone='415.555.1212',
    AccountId=acctID);
insert mario;



// Update Related Records----------

// Query for the contact, which has been associated with an account.
Contact queriedContact = [SELECT Account.Name 
                          FROM Contact 
                          WHERE FirstName = 'Mario' AND LastName='Ruiz'
                          LIMIT 1];
// Update the contact's phone number
queriedContact.Phone = '(415)555-1213';
// Update the related account industry
queriedContact.Account.Industry = 'Technology';
// Make two separate calls 
// 1. This call is to update the contact's phone.
update queriedContact;
// 2. This call is to update the related account's Industry field.
update queriedContact.Account; 


// Delete Related Records--------------------------

Account[] queriedAccounts = [SELECT Id FROM Account WHERE Name='SFDC Account'];
delete queriedAccounts;

// Create a method for inserting accounts DML. CHALLAENGE
public class AccountHandler {
    public static Account insertNewAccount(String name)
    {
        Account acct = new Account(Name=name);
        try
        {
            insert acct;
            return acct
        }
        catch(DmlException e)
        {
            System.debug('A DML exception has occurred: ' +
                e.getMessage());
                return null
        }

    }
}

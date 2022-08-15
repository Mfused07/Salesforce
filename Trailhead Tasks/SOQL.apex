//  SOQL statement
// the following retrieves all account records with two fields, Name and Phone, and returns an array of Account sObjects.
Account[] accts = [SELECT Name,Phone FROM Account];

// Basic SOQL Syntax
SELECT Name, Phone FROM Account
SELECT fields FROM ObjectName [WHERE Condition]
// WHERE Condition is optional and can be used to filter the records returned. The WHERE clause can contain multiple conditions, and can be combined with AND and OR operators.

//Where Filter
SELECT Name, Phone 
FROM Account 
WHERE Name='SFDC Computing'

SELECT Name, Phone 
FROM Account 
WHERE (Name='SFDC Computing' AND NumberOfEmployees>25)

// Combine AND + OR in Where Filter

SELECT Name, Phone 
FROM Account 
WHERE (Name='SFDC Computing' OR (NumberOfEmployees>25 AND BillingCity='Los Angeles'))


// Account Object accts
Account[] accts = [SELECT Name,Phone FROM Account 
                   WHERE (Name='SFDC Computing' AND NumberOfEmployees>25)
                   ORDER BY Name
                   LIMIT 10];
System.debug(accts.size() + ' account(s) returned.');
// Write all account array info
System.debug(accts);

USER_DEBUG [7]|DEBUG|(Account:{Name=SFDC Computing, Phone=(415)555-1212, Id=0015h00000wBO4qAAG, RecordTypeId=0125h000000ZxOmAAK})

// This next example embeds the example SOQL query in Apex and shows how to get the child records from the SOQL result by using the Contacts relationship name on the sObject.

Account[] acctsWithContacts = [SELECT Name, (SELECT FirstName,LastName FROM Contacts)
                               FROM Account 
                               WHERE Name = 'SFDC Computing'];
// Get child records
Contact[] cts = acctsWithContacts[0].Contacts;
System.debug('Name of first associated contact: ' 
             + cts[0].FirstName + ', ' + cts[0].LastName);

// Name of first associated contact: Carol, Ruiz


Contact[] cts = [SELECT Account.Name FROM Contact 
                 WHERE FirstName = 'Carol' AND LastName='Ruiz'];
Contact carol = cts[0];
String acctName = carol.Account.Name;
System.debug('Carol\'s account name is ' + acctName);
// DEBUG|Carol's account name is SFDC Computing

// Challenge SOQL
//searches for contacts that have a last name matching the first string and a mailing postal code matching the second. It gets the ID and Name of those contacts and returns them.

public static List<Contact> searchForContacts(String lastName, String postalCode) {
    List<Contact> contacts = [SELECT Id, Name FROM Contact 
                              WHERE LastName = :lastName AND MailingPostalCode = :postalCode];
    return contacts;
}

// Salesforce Object Search Language (SOSL) 
// perform text searches in records .

// SYNTAX

FIND 'SearchQuery' [IN SearchGroup] [RETURNING ObjectsAndFields]

// Search group -> Optional 

// SearchGroup can take one of the following values.
// NAME FIELDS
// EMAIL FIELDS
// PHONE FIELDS
// SIDEBAR FIELDS




// 1-SOSL query that searches for accounts and contacts 
    // that have any fields with the word 'SFDC'.

List<List<SObject>> searchList = [FIND 'SFDC' IN ALL FIELDS 
                                RETURNING Account(Name),
                                Contact(FirstName,LastName)];

//2- SOQL can only query one standard or custom object at a time -> searching for ('Digital') resturns 'Digital'
//Single SOSL query can search all objects. -> searching for 'Digital' returns ('Digital' or 'The Digital Company)




// Add account and related contact----------
Account acct = new Account(
    Name='SFDC Computing',
    Phone='(415)555-1212',
    NumberOfEmployees=50,
    BillingCity='San Francisco');
insert acct;
// Once the account is inserted, the sObject will be 
// populated with an ID.
// Get this ID.
ID acctID = acct.ID;
// Add a contact to this account.
Contact con = new Contact(
    FirstName='Carol',
    LastName='Ruiz',
    Phone='(415)555-1212',
    Department='Wingo',
    AccountId=acctID);
insert con;
// Add account with no contact
Account acct2 = new Account(
    Name='The SFDC Query Man',
    Phone='(310)555-1213',
    NumberOfEmployees=50,
    BillingCity='Los Angeles',
    Description='Expert in wing technologies.');
insert acct2;

FIND {Wingo} IN ALL FIELDS RETURNING
 Account(Name),
  Contact(FirstName,LastName,Department)

// The search query in the Query Editor and the API must
//  be enclosed within curly brackets ({Wingo}). In contrast,
//   in Apex the search query is enclosed within single quotes ('Wingo').



// 3- SOSL query that searches for accounts and contacts soslFindClause 
String soslFindClause = 'Wingo OR SFDC';

List<List<sObject>> searchList = [FIND :soslFindClause IN ALL FIELDS
                    RETURNING Account(Name),
                    Contact(FirstName,LastName,Department)];

Account[] searchAccounts = (Account[])searchList[0];
Contact[] searchContacts = (Contact[])searchList[1];

System.debug('Found the following accounts.');
for (Account a : searchAccounts) 
{
    System.debug(a.Name);
}

System.debug('Found the following contacts.');
for (Contact c : searchContacts) 
{
    System.debug(c.LastName + ', ' + c.FirstName);
}

// create an Apex class that returns both contacts and leads that have first or last name matching the incoming parameter
public class SearchContactsAndLeads {
    public static List<sObject> searchContactsAndLeads(String searchName) {
        List<List<sObject>> searchList = [FIND :searchName IN ALL FIELDS
                    RETURNING Contact(FirstName,LastName),
                    Lead(FirstName,LastName)];
        List<sObject> searchResults = new List<sObject>();
        searchResults.addAll(searchList[0]);
        searchResults.addAll(searchList[1]);
        return searchResults;
    }
}

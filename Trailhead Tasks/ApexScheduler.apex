// Create an Apex class that implements the Schedulable interface to update Lead records with a specific LeadSource.
public class DailyLeadProcessor implements Schedulable {
    public void execute(SchedulableContext ctx) {
        // The execute method must find the first 200 Lead records with a blank LeadSource field and 
        // update them with the LeadSource value of Dreamforce
        List<Lead> leads = [SELECT Id FROM Lead WHERE LeadSource = null LIMIT 200];
        for (Lead leadRecord : leads) {
            leadRecord.LeadSource = 'Dreamforce';
        }
        update leads;
    }
}
DailyLeadProcessor dlp = new DailyLeadProcessor();
// Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
String jobID = System.schedule('Update Leads', '0 0 0 4 8 ? 2022', dlp);

//insert 200 Lead records, schedule the DailyLeadProcessor class to run and test that all Lead records were updated correctly
@isTest
public class DailyLeadProcessorTest {
    static testMethod void testDailyLeadProcessor() {
        // Create 200 Lead records with a blank LeadSource field
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 200; i++) {
            Lead leadRecord = new Lead(
                FirstName = 'John' + i,
                LastName = 'Doe',
                Company = 'The Company',
            );
            leads.add(leadRecord);
        }
        insert leads;
        Test.startTest();
        // Schedule the DailyLeadProcessor class to run
        String jobID = System.schedule('Update Leads', '0 0 0 4 8 ? 2022', new DailyLeadProcessor());
        Test.stopTest();
        // Test that all Lead records were updated correctly
        List<Lead> updatedLeads = [SELECT Id FROM Lead WHERE LeadSource = 'Dreamforce' and Company = 'The Company'];
        System.assertEquals(200, updatedLeads.size(),'lead records were not updated correctly');
    }
}

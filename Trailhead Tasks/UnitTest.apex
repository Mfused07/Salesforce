
// my regular method 

public class TemperatureConverter {
    // Takes a Fahrenheit temperature and returns the Celsius equivalent.
    public static Decimal FahrenheitToCelsius(Decimal fh) {
        Decimal cs = (fh - 32) * 5/9;
        return cs.setScale(2);
    }
}

// test For above method

@isTest
private class TemperatureConverterTest {
    @isTest static void testWarmTemp() {
        Decimal celsius = TemperatureConverter.FahrenheitToCelsius(70);
        System.assertEquals(21.11,celsius);
    }
    @isTest static void testFreezingPoint() {
        Decimal celsius = TemperatureConverter.FahrenheitToCelsius(32);
        System.assertEquals(0,celsius);
    }
    @isTest static void testBoilingPoint() {
        Decimal celsius = TemperatureConverter.FahrenheitToCelsius(212);        
        System.assertEquals(100,celsius,'Boiling point temperature is not expected.');
    } 
    @isTest static void testNegativeTemp() {
        Decimal celsius = TemperatureConverter.FahrenheitToCelsius(-10);
        System.assertEquals(-23.33,celsius);
    }
}


//get task priority for string lead state class TaskUtil
public class TaskUtil {
    public static String getTaskPriority(String leadState) {
        // Validate input
        if (String.isBlank(leadState) || leadState.length() > 2) {
            return null;
        }
        String taskPriority;
        if (leadState == 'CA') {
             taskPriority = 'High'; 
        } else {
             taskPriority = 'Normal';
        }
        return taskPriority;
    }
}

// test for class TaskUtil 100% test coverage

@isTest
private class TaskUtilTest {
    @isTest static void testTaskPriority(){
        String taskPriority = TaskUtil.getTaskPriority('NY');
        System.asserEquals('Normal', taskPriority);
    }


    @isTest static void testTaskHighPriority(){
        String taskPriority = TaskUtil.getTaskPriority('CA');
        System.asserEquals('High', taskPriority);
    }

    @isTest static void testTaskPriorityInvalid(){
        String taskPriority = TaskUtil.getTaskPriority('CA');
        System.asserEquals(null, taskPriority);
    }
}


// Test for Verify Date Challenge-----------------------------

public class VerifyDate {
	
	//method to handle potential checks against two dates
	public static Date CheckDates(Date date1, Date date2) {
		//if date2 is within the next 30 days of date1, use date2.  Otherwise use the end of the month
		if(DateWithin30Days(date1,date2)) {
			return date2;
		} else {
			return SetEndOfMonthDate(date1);
		}
	}
	
	//method to check if date2 is within the next 30 days of date1
	private static Boolean DateWithin30Days(Date date1, Date date2) {
		//check for date2 being in the past
        	if( date2 < date1) { return false; }
        
        	//check that date2 is within (>=) 30 days of date1
        	Date date30Days = date1.addDays(30); //create a date 30 days away from date1
		if( date2 >= date30Days ) { return false; }
		else { return true; }
	}

	//method to return the end of the month of a given date
	private static Date SetEndOfMonthDate(Date date1) {
		Integer totalDays = Date.daysInMonth(date1.year(), date1.month());
		Date lastDay = Date.newInstance(date1.year(), date1.month(), totalDays);
		return lastDay;
	}

}

@isTest
private class TestVerifyDate {
    @isTest static void testDateWithin30Days() {
        Date date1 = Date.newInstance(2018, 1, 1);
        Date date2 = Date.newInstance(2018, 1, 30);
        Date result = VerifyDate.CheckDates(date1, date2);
        System.assertEquals(date2, result);
    }
    @isTest static void testDateNotWithin30Days() {
        Date date1 = Date.newInstance(2018, 1, 1);
        Date date2 = Date.newInstance(2018, 2, 1);
        Date result = VerifyDate.CheckDates(date1, date2);
        System.assertEquals(Date.newInstance(2018, 1, 31), result);
    }
     @isTest static void testDateBetween30Days() {
    Date date1 = Date.newInstance(2018, 1, 1);
    Date date2 = Date.newInstance(2018, 1, 31);
    Date result = VerifyDate.CheckDates(date1, date2);
    System.assertEquals(Date.newInstance(2018, 1, 1), result);
    }
    // @isTest static void testDateBetween30Days() {
    // Date date1 = Date.newInstance(2018, 1, 1);
    // Date date2 = Date.newInstance(2018, 1, 31);
    // Date result = VerifyDate.CheckDates(date1, date2);
    // System.assertEquals(Date.newInstance(2018, 1, 1), result);
    // }

}









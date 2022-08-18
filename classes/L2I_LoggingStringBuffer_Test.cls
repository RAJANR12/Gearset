/* ===============================================================================
* This code is an adaptation of the "apex-lang" open source project available at:
*
*      http://code.google.com/p/apex-lang/
*
* This code is licensed under the Apache License, Version 2.0.  You may obtain a
* copy of the License at:
*
*      http://www.apache.org/licenses/LICENSE-2.0
* ===============================================================================
*/
@IsTest
private class L2I_LoggingStringBuffer_Test {

    private static testMethod void testDecimal(){
        Decimal value = 3.14159;
        System.assertEquals((new L2I_LoggingStringBuffer(value)).append(value).toStr(), ''+value+'\n'+value);
        System.assertEquals((new L2I_LoggingStringBuffer(value)).append(value).append(value).toStr(), ''+value+'\n'+value+'\n'+value);
    }

    private static testMethod void testDouble(){
        Double value = 3.14159;
        System.assertEquals((new L2I_LoggingStringBuffer(value)).append(value).toStr(), ''+value+'\n'+value);
        System.assertEquals((new L2I_LoggingStringBuffer(value)).append(value).append(value).toStr(), ''+value+'\n'+value+'\n'+value);
    }

    private static testMethod void testInteger(){
        Integer value = 792392;
        System.assertEquals((new L2I_LoggingStringBuffer(value)).append(value).toStr(), ''+value+'\n'+value);
        System.assertEquals((new L2I_LoggingStringBuffer(value)).append(value).append(value).toStr(), ''+value+'\n'+value+'\n'+value);
    }

    private static testMethod void testLong(){
        Long value = 792392;
        System.assertEquals((new L2I_LoggingStringBuffer(value)).append(value).toStr(), ''+value+'\n'+value);
        System.assertEquals((new L2I_LoggingStringBuffer(value)).append(value).append(value).toStr(), ''+value+'\n'+value+'\n'+value);
    }

    private static testMethod void testID(){
        Account foo = new Account(name='test');
        insert foo;
        Id value = foo.id;
        System.assertEquals((new L2I_LoggingStringBuffer(value)).append(value).toStr(), ''+value+'\n'+value);
        System.assertEquals((new L2I_LoggingStringBuffer(value)).append(value).append(value).toStr(), ''+value+'\n'+value+'\n'+value);
    }

    private static testMethod void testBoolean(){
        Boolean value = true;
        System.assertEquals((new L2I_LoggingStringBuffer(value)).append(value).toStr(), ''+value+'\n'+value);
        System.assertEquals((new L2I_LoggingStringBuffer(value)).append(value).append(!value).toStr(), ''+value+'\n'+value+'\n'+(!value));
    }

    private static testMethod void testString(){
        String value = 'rwkrfkdekf';
        System.assertEquals((new L2I_LoggingStringBuffer()).append(value).toStr(), ''+value);
        System.assertEquals((new L2I_LoggingStringBuffer()).append(value).append(value).toStr(), ''+value+'\n'+value);
        System.assertEquals((new L2I_LoggingStringBuffer(value)).append(value).toStr(), ''+value+'\n'+value);
        System.assertEquals((new L2I_LoggingStringBuffer(value)).append(value).append(value).toStr(), ''+value+'\n'+value+'\n'+value);
    }

    private static testMethod void testDate(){
        Date value = date.newinstance(1960, 2, 17);
        System.assertEquals((new L2I_LoggingStringBuffer(value)).append(value).toStr(), ''+value+'\n'+value);
        System.assertEquals((new L2I_LoggingStringBuffer(value)).append(value).append(value).toStr(), ''+value+'\n'+value+'\n'+value);
    }

    private static testMethod void testDatetime(){
        Datetime value = datetime.newInstance(2008, 12, 1);
        System.assertEquals((new L2I_LoggingStringBuffer(value)).append(value).toStr(), ''+value+'\n'+value);
        System.assertEquals((new L2I_LoggingStringBuffer(value)).append(value).append(value).toStr(), ''+value+'\n'+value+'\n'+value);
    }

    private static testMethod void testTime(){
        Time value = Time.newInstance(18, 30, 2, 20);
        System.assertEquals((new L2I_LoggingStringBuffer(value)).append(value).toStr(), ''+value+'\n'+value);
        System.assertEquals((new L2I_LoggingStringBuffer(value)).append(value).append(value).toStr(), ''+value+'\n'+value+'\n'+value);
    }

    private static testMethod void testBlob(){
        Blob value = Blob.valueOf('test123');
        System.assertEquals((new L2I_LoggingStringBuffer(value)).append(value).toStr(), ''+value+'\n'+value);
        System.assertEquals((new L2I_LoggingStringBuffer(value)).append(value).append(value).toStr(), ''+value+'\n'+value+'\n'+value);
    }

    private static testMethod void testLargeString() {
        Integer MAX_BUFFER_SIZE = 32768 - 15;
        String value = L2I_UtilityHelper.generateRandomString(MAX_BUFFER_SIZE);
        System.assertEquals((new L2I_LoggingStringBuffer()).append(value).toStr(), ''+value);
        System.assertEquals((new L2I_LoggingStringBuffer()).append(value).append('Something that exceeds the buffer size').toStr(), ''+value+'\n*TRUNCATED*');
    }

}
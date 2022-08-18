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
global class L2I_LoggingStringBuffer {
    private static Integer MAX_BUFFER_SIZE = 32768 - 15; //\nTRUNCATED
    private String theString;

    global L2I_LoggingStringBuffer(){
        this('');
    }

    global L2I_LoggingStringBuffer(String str){
        theString = str;
        System.debug(theString);
    }

    global L2I_LoggingStringBuffer(Decimal d){
        theString = '' + d;
        System.debug(theString);
    }

    global L2I_LoggingStringBuffer(Double d){
        theString = '' + d;
        System.debug(theString);
    }

    global L2I_LoggingStringBuffer(Long l){
        theString = '' + l;
        System.debug(theString);
    }

    global L2I_LoggingStringBuffer(Integer i){
        theString = '' + i;
        System.debug(theString);
    }

    global L2I_LoggingStringBuffer(Blob b){
        theString = '' + b;
        System.debug(theString);
    }

    global L2I_LoggingStringBuffer(Boolean b){
        theString = '' + b;
        System.debug(theString);
    }

    global L2I_LoggingStringBuffer(Date d){
        theString = '' + d;
        System.debug(theString);
    }

    global L2I_LoggingStringBuffer(Datetime d){
        theString = '' + d;
        System.debug(theString);
    }

    global L2I_LoggingStringBuffer(ID id){
        theString = '' + id;
        System.debug(theString);
    }

    global L2I_LoggingStringBuffer(Time t){
        theString = '' + t;
        System.debug(theString);
    }

    global L2I_LoggingStringBuffer append(String str){
        // we'll only keep appending to the stringbuffer up to the MAX_BUFFER_SIZE
        if (theString.length() + str.length() <=  MAX_BUFFER_SIZE) {
            if (theString.length() == 0) {
                theString += str;
            } else {
                theString += '\n'+str;
            }
        } else {
            theString += '\n*TRUNCATED*';
        }

        System.debug(str);
        return this;
    }

    global L2I_LoggingStringBuffer append(Decimal d){
        theString += '\n'+d;
        System.debug(''+d);
        return this;
    }

    global L2I_LoggingStringBuffer append(Double d){
        theString += '\n'+d;
        System.debug(''+d);
        return this;
    }

    global L2I_LoggingStringBuffer append(Long l){
        theString += '\n'+l;
        System.debug(''+l);
        return this;
    }

    global L2I_LoggingStringBuffer append(Integer i){
        theString += '\n'+i;
        System.debug(''+i);
        return this;
    }

    global L2I_LoggingStringBuffer append(Blob b){
        theString += '\n'+b;
        System.debug(''+b);
        return this;
    }

    global L2I_LoggingStringBuffer append(Boolean b){
        theString += '\n'+b;
        System.debug(''+b);
        return this;
    }

    global L2I_LoggingStringBuffer append(Date d){
        theString += '\n'+d;
        System.debug(''+d);
        return this;
    }

    global L2I_LoggingStringBuffer append(Datetime d){
        theString += '\n'+d;
        System.debug(''+d);
        return this;
    }

    global L2I_LoggingStringBuffer append(ID id){
        theString += '\n'+id;
        System.debug(''+id);
        return this;
    }

    global L2I_LoggingStringBuffer append(Time t){
        theString += '\n'+t;
        System.debug(''+t);
        return this;
    }

    global String toStr(){
        return theString;
    }
}
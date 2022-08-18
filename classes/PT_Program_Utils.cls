/**
 *      @author       Dan Morris
 *      @date         06/25/2020
 *      @description  Program Table Utility methods
 *
 *      Modification Log:
 *      ------------------------------------------------------------------------------------
 *      Developer                       Date                Description
 *      ------------------------------------------------------------------------------------
 *      Dan Morris                   06/25/2020         Initial scaffold
 *      Dan Morris                   07/17/2020         Refactors, clean up program sequence and aircraft regex
 *
 */
public class PT_Program_Utils {
    private static String parseAcType(String acType, String programCode) {
        System.debug('********* ' + acType);
        if (acType == 'Mixed') {
            System.debug('parseAcType: MIX');
            return 'MIX';
        }
        // Field out the Aircraft type and walk the match groups to create the pattern
        // At create, 5 groups. Can change to accomodate more types
        // Pattern acProgram = pattern.compile('^(A*)([0-9]{2})([0-9])(-)*( MAX )*');
        //Pattern acProgram = pattern.compile('^(?:A*)([0-9]{2})([0-9])(-| MAX )*(([0-9])(?:[0-9]{2})?)*');
        //Matcher acMatcher = acProgram.matcher(acType);
        if (programCode != null) {
            return programCode;
        } else {
            return '___';
        }
        /*
        if (!acMatcher.find()) {
            System.debug('parseAcType: FAILED TO MATCH ['+acType+']');
            return '___';
        }
        String charAssignment;
        if (acMatcher.group(3) == '-' || acMatcher.group(3) == ' MAX ') {
            charAssignment = acMatcher.group(1) + acMatcher.group(5);
        } else {
            charAssignment = acMatcher.group(1) + acMatcher.group(2);
        }
        return charAssignment;
        */
    }

    /**
     * simple function to encode an alpha Revision character
     * Uses only (non-ambiguous) alpha characters
     * go to 2 alpha digits (not padded)
     * Input: Numeric
     * Output: Corresponding "Revision" character
     */
    public static String revisionCharacter(Integer revision) {
        /*String charIndex = 'ABCDEFGHJKLMNPRTUVWY';
        Integer modulus = charIndex.length();
        String thisRevision = '';
        while (revision > 0) {
            Integer thisDigit = math.mod(revision, modulus) == 0 ? modulus : math.mod(revision, modulus);
            thisRevision += charIndex.mid(thisDigit - 1, 1);
            revision = math.mod(revision, modulus) == 0 ? (revision / modulus) -1 : (revision / modulus);
        }
        return thisRevision.reverse();*/
        
        // Updated by Lipton for W-003404
        String charIndex = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        Integer charLength = charIndex.length();
        String result = '';
        
        if (revision == 0 || revision == null) {
            return result;
        }
        
        if (revision <= charLength) {
            result += charIndex.substring(revision - 1, revision);
        } else {
            Integer floor = (Integer)Math.floor(revision / charLength);
            Integer remainder = Math.mod(revision, charLength);
            if (remainder == 0) {
                result += revisionCharacter(floor - 1);
                result += revisionCharacter(26);
            } else {
                result += revisionCharacter(floor);
                result += revisionCharacter(remainder);
            }
        }
        
        return result;
    }

    /**
     * simple function to encode a 2 digit sequence (0-359)
     * Ones value is [0-9]
     * 'Tens' value is [0-9A-Z]
     * Input: Sequence value
     * Output: Next sequence value
     */
    public static String characterSequencer(String sequence) {
        String charIndex = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        Integer numeric = 0;
        if(sequence.isNumeric()){
            numeric = Integer.valueOf(sequence)  + 1;  // Next sequence value...
        } else {
            numeric =
              charIndex.indexOfIgnoreCase(sequence.mid(0,1)) * 10
            + charIndex.indexOfIgnoreCase(sequence.mid(1,1))
            + 1;  // Next sequence value...
        }
        String nextSequence =
              charIndex.mid((numeric)/10,1)
            + charIndex.mid((math.mod(numeric,10)),1);
        System.debug('PT_Program_Utils.characterSequencer: Input: ' + sequence + ' Output: ' + nextSequence);
        return nextSequence;
    }
    /**
        Character 1               SBQQ__PrimaryQuote__r.L2I_Primary_System_Type__r.L2I_System_Type_Translation__c - Use it as is.
        Character 2-3             Account.L2I_Operator_Number__c
        Character 4-6             L2I_AircraftType__c.L2I_Aircraft_Type__c Translate via table - maybe on aircraft type record
    */
    public static String getCoreProgramName(String systemType, String customerCode, String acType, String programCode) {
//        String customerNumber = (customerCode == null || customerCode == '') ? '##' : customerCode;
        String customerNumber = (customerCode == null || customerCode == '') ? '__' : customerCode;
        String aircraft = parseAcType(acType, programCode);
        String typeChar = systemType != null ? systemType : '-';
        Boolean isB787 = aircraft.left(2) == '78';
        if (typeChar == 'A' && isB787)  typeChar = 'B'; // Hack to address eX2 for B787
        String coreProgram = typeChar + customerNumber + aircraft;
        return (coreProgram);
    }

    @future
    public static void udpateProgramAircrafts (Id opptyId, Id progId) {
        String aircraftIds = '';
        for (L2I_DSL__c dsl : [SELECT Id, Name, Aircraft__c, PT_Program__c
                                FROM L2I_DSL__c
                                WHERE Original_Opportunity__c = :opptyId AND PT_Program__c = :progId AND Aircraft__c != null]) {
        aircraftIds = aircraftIds + dsl.Aircraft__c + ';';
        }
        PT_Program__c prog = new PT_Program__c (Id = progId, PT_Program_Aircraft_IDs__c = aircraftIds);
        update prog;
    }
    /**
     * Determine the NEXT Program Number Sequence Value
     * Input: Core Program number (Left 6 characters)
     * Output: Sequence string for program
     */
    /*
    private static String nextProgramSequence(String coreProgramNumber) {
        if (!isProgramQueried) {
            List<AggregateResult> programSequences = [SELECT Core_Program__c, MAX(Program_Number__c) HIGHSEQ
                                                        FROM PT_Program__c
                                                        WHERE Core_Program__c !=  null
                                                        GROUP BY Core_Program__c ];
            isProgramQueried = true;
            for (AggregateResult ar : programSequences) {
                programHighSequence.put((String)ar.get('Core_Program__c'), ((String)ar.get('HIGHSEQ')).mid(6,2));
            }
        }
        String sequence = programHighSequence.get(coreProgramNumber) == null ? '00' : programHighSequence.get(coreProgramNumber);
        return characterSequencer(sequence);
    }

    public static String ProgramName(String systemType, String customerCode, String acType) {
        String customerNumber = (customerCode == null || customerCode == '') ? '##' : customerCode;
        String aircraft = parseAcType(acType);
        String typeChar = systemType != null ? systemType : '-';
        Boolean isB787 = aircraft.left(2) == '78';
        if (typeChar == 'A' && isB787)  typeChar = 'B'; // Hack to address eX2 for B787
        String coreProgram = typeChar + customerNumber + aircraft;
        String sequence = nextProgramSequence(coreProgram);
        programHighSequence.put(coreProgram, sequence);
        System.debug('PT_Program_Utils.ProgramName  SystemType: ['+systemType+']['+typeChar+'] customerNumber: ['+customerNumber+'] aircraft: ['+acType+']['+aircraft+'] coreProgram: ['+coreProgram+'] programSequence: ['+sequence+']');
        return (coreProgram + sequence);
    }
    */
}
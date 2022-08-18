trigger Ife_LeadTrigger on Lead(after insert){
	if (trigger.isAfter && trigger.isInsert){
        Ife_LeadTriggerHandler.afterInsert(trigger.new);
	}
}
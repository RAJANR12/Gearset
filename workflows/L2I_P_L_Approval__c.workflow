<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>P_L_Has_Been_Approved</fullName>
        <description>P&amp;L Has Been Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/P_L_Approved_Template</template>
    </alerts>
    <alerts>
        <fullName>P_L_Has_Been_Rejected</fullName>
        <description>P&amp;L Has Been Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/P_L_Rejected_Template</template>
    </alerts>
    <fieldUpdates>
        <fullName>P_L_Approval_Integration_Message_Update</fullName>
        <field>L2I_IntegrationMessage__c</field>
        <name>P&amp;L Approval Integration Message Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>P_L_Approval_Integration_Status_Update</fullName>
        <field>L2I_IntegrationStatus__c</field>
        <literalValue>Ready to Integrate</literalValue>
        <name>P&amp;L Approval Integration Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Has_Store_Calculations</fullName>
        <description>Set Has Store Calculations to true</description>
        <field>Has_Stored_Calculations__c</field>
        <literalValue>1</literalValue>
        <name>Set Has Store Calculations</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Status_to_Pending</fullName>
        <field>ApprovalStatus__c</field>
        <literalValue>Pending</literalValue>
        <name>Update Approval Status to Pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Status_to_Recalled</fullName>
        <field>ApprovalStatus__c</field>
        <literalValue>Recalled</literalValue>
        <name>Update Approval Status to Recalled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Status_to_Rejected</fullName>
        <field>ApprovalStatus__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update Approval Status to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Approved</fullName>
        <field>ApprovalStatus__c</field>
        <literalValue>Approved</literalValue>
        <name>Update Status to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
</Workflow>

public with sharing class CustomOppGetTax
extends AVA_SFCORE.GetTaxOpportunity
{
	private List<Opportunity> clopps;
	
    // query for the additional custom fields to be used in FetchDestinationAddress and FetchTaxData
	public CustomOppGetTax(ApexPages.StandardController controller)
	{
		clopps = [select Id, Ship_to_Address__c, Ship_to_Address_2__c, Ship_to_City__c, 
        	Ship_to_State__c, Ship_to_Zip__c, Ship_to_Country__c, Service_Address1__c, Service_Address2__c,
        	Service_City__c, Service_State__c, Service_Zip__c, Sales_Tax_Exempt__c, Oppty_Specific_EBS__c
        	from Opportunity where Id=:loOpp[0].Id];		
	}
	
	// Override FetchDestination Address to fetch from custom fields
	public override AVA_SF_SDK.TaxSvc.BaseAddress FetchDestinationAddress()
	{     
        AVA_SF_SDK.TaxSvc.BaseAddress oDestinationAddress = new AVA_SF_SDK.TaxSvc.BaseAddress();
        oDestinationAddress.AddressCode = 'D';
        if(loCfg[0].AVA_SFCORE__Use_BillingAddress__c == true)
        {
        // use service address
	        oDestinationAddress.Line1 = clopps[0].Service_Address1__c;
            oDestinationAddress.Line2 = clopps[0].Service_Address2__c;
            oDestinationAddress.City = clopps[0].Service_City__c;
            oDestinationAddress.Region = clopps[0].Service_State__c;
            oDestinationAddress.PostalCode = clopps[0].Service_Zip__c;
        }
        else
        {
            // use ship_to address
	        oDestinationAddress.Line1 = clopps[0].Ship_to_Address__c;
            oDestinationAddress.Line2 = clopps[0].Ship_to_Address_2__c;
            oDestinationAddress.City = clopps[0].Ship_to_City__c;
            oDestinationAddress.Region = clopps[0].Ship_to_State__c;
            oDestinationAddress.PostalCode = clopps[0].Ship_to_Zip__c;
            oDestinationAddress.Country = clopps[0].Ship_to_Country__c;
        }
		
		return oDestinationAddress;	
	}
	
	// Override FetchTaxData to account for Exempt flag and Company Code
	public override AVA_SF_SDK.TaxSvc.GetTaxRequest FetchTaxData(Boolean commitFlag)
	{
		AVA_SF_SDK.TaxSvc.GetTaxRequest rVal = super.FetchTaxData(commitFlag);
		if(clopps[0].Sales_Tax_Exempt__c == 'Yes')
		{
			rVal.ExemptionNo = 'Exempt';
		}
		else
		{
			rVal.ExemptionNo = '';
		}
		rVal.CompanyCode = clopps[0].Oppty_Specific_EBS__c;
		
		return rVal;
	}
}
/**
 * @description       :  AccountCreateService class is responsible for creating an account in the system SAP
 * @author            : Christian Niro
 * @group             : 
 * @last modified on  : 06-22-2026
 * @last modified by  : Christian Niro
**/
public class AccountCreateService {

    public static String INTEGRATION_FLOW = 'SF-ACC-01';

    private String accountId;

    public AccountCreateService(String accountId) {
        this.accountId = accountId;
    }

    public String execute(){
        String result;
        Map<String, Object> dataMap = loadData();
        checkMandatoryFields(dataMap);
        String jsonRequest = buildRequest(dataMap);
        Map<String, Object> responseMap = sendRequest(jsonRequest);
        result =  manageResponse(responseMap);
        return result;
    }

    public Map<String, Object> loadData() {
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, List<Ship_To__c>> shipToMap = new Map<String, List<Ship_To__c>>();
        Map<String, SalesAreaShipTo__c> salesAreaToShipToMap = new Map<String, SalesAreaShipTo__c>();

        List<Account> accountToSendList = 
            [SELECT Id, name1__c,name2__c,name3__c,name4__c,Fiscal_Code__c,VAT_Number__c,VAT_Reg_No__c,isNatural_Person__c,
                Phone,Fax,User_Type__c,E_Invoicing_Certified_Email__c,Interchange_System_SDI__c,E_Invoicing_Type__c,Account_Number__c,
                BillingCity,BillingCountryCode,BillingPostalCode,BillingStateCode,BillingStreet,Terms_of_payment__c,Iban__c,
                Language_Code__c,Transport_Area__c,Internal_Bank__c,Account_Balance__c,Account_Group__c,Company_Code__c,interno_fax__c,
                Reconciliation_Account__c,Sort_Key__c,login_code__c,mobile_phone__c,isBranchOffice__c,Search_concept__c,interno_phone__c,
                tech_invoice_attr1__c,tech_invoice_attr2__c,electronic_signature__c,Logic_Deletion__c,
                (SELECT FLG_NOUSE__c,flg_default__c,Email,Email_Type__c,ExternId__c FROM Contacts WHERE recordtype.developername =: 'RT_Contact_Email')
            FROM Account 
            WHERE id = :this.accountId];
        
        if(accountToSendList == null || accountToSendList.size() == 0){
            throw new AccountCreateServiceException('Account not found'); //da flusso non dovrebbe essere possibile
        }

        List<Sales_Area__c> salesAreaToSendList = 
            [SELECT Id,ExternId__c,Payment_agreement__c,Sales_Organization__c,Distribution_Channel__c,Customer_Group__c,
                Shipping_method_code__c,Warehouse__c,Distribution_Area__c,Sales_Office__c,Sales_Team__c,Max_Partial_Delivery__c,
                Billing_Calendar__c,Bonus__c,Credit_ctrl_area__c,Currency__c,Shipping_Conditions__c,Shipping_Method_Description__c,
                Account_Assignment_Group__c,Tax_Classification_VAT__c,Tax_Classification_VAT_Exemption__c,Cust_Pric_Proc__c,
                Cust_Stats_Grp__c,Service_Type__c,Delivery_Priority__c,Orders_Bundle__c,Service_Manager__c,merge_invoices__c,
                (SELECT Id,Code__c,Type__c FROM Payer_Accounts__r),
                (SELECT 
                    Id,Partner_default__c,Ship_To__c,Sales_Area__c,
                    Warehouse__c,Service_Type__c,Orders_Bundle__c,Shipping_Conditions__c,Shipping_Method_Description__c,Shipping_method_code__c,
                    Service_Manager__c
                 FROM SalesAreaShipTo__r)
            FROM Sales_Area__c 
            WHERE Account__c = :this.accountId];

        if(salesAreaToSendList != null && salesAreaToSendList.size() > 0){

            System.debug('salesAreaToSendList.size['+salesAreaToSendList.size()+']');
            Map<String, List<String>> salesAreaShipToMap = new Map<String, List<String>>();
            
            for(Sales_Area__c curSalesArea : salesAreaToSendList){
                List<SalesAreaShipTo__c> curSalesAreaShipToList = curSalesArea.SalesAreaShipTo__r;
                if(curSalesAreaShipToList != null && curSalesAreaShipToList.size() > 0){
                    for(SalesAreaShipTo__c curSalesAreaShipTo : curSalesAreaShipToList){
                        if(!String.isBlank(curSalesAreaShipTo.Ship_To__c)){
                            if(!salesAreaShipToMap.containsKey(curSalesArea.Id)){
                                salesAreaShipToMap.put(curSalesArea.Id, new List<String>());
                            }
                            salesAreaShipToMap.get(curSalesArea.Id).add(curSalesAreaShipTo.Ship_To__c);
                            salesAreaToShipToMap.put(curSalesArea.Id+'|'+curSalesAreaShipTo.Ship_To__c, curSalesAreaShipTo);
                        }
                    }
                }
            }

            if(salesAreaShipToMap.keySet()!=null && salesAreaShipToMap.keySet().size()>0){
                
                List<String> shipToIdList = new List<String>();
                for(List<String> curShipToList : salesAreaShipToMap.values()){
                    shipToIdList.addAll(curShipToList);
                }

                Map<Id, Ship_To__c> shipToSelectedMap = new Map<ID, Ship_To__c>(
                    [SELECT Id,ExternId__c,Ship_To_Number__c,Tax_Classification_VAT__c,Tax_Classification_VAT_Exemption__c,VAT_Number__c,
                        name1__c,name2__c,name3__c,name4__c,Address__City__s,Address__CountryCode__s,Address__PostalCode__s,
                        Address__StateCode__s,Address__Street__s,Transport_Area__c,Warehouse__c,Service_Type__c,Orders_Bundle__c,
                        Shipping_Conditions__c,Shipping_Method_Description__c,Shipping_method_code__c,Service_Manager__c,
                        (SELECT FLG_NOUSE__c,flg_default__c,Email,Email_Type__c,ExternId__c FROM Contacts__r WHERE recordtype.developername =: 'RT_Contact_Email')
                    FROM Ship_To__c 
                    WHERE Id IN :shipToIdList]);
                
                if(shipToSelectedMap!=null && shipToSelectedMap.keySet()!=null && shipToSelectedMap.keySet().size()>0){
                    for(String curSalesAreaId : salesAreaShipToMap.keySet()){
                        for(String curShipToId : salesAreaShipToMap.get(curSalesAreaId)){
                            if(shipToSelectedMap.containsKey(curShipToId)){
                                if(!shipToMap.containsKey(curSalesAreaId)){
                                    shipToMap.put(curSalesAreaId, new List<Ship_To__c>());
                                }
                                shipToMap.get(curSalesAreaId).add(shipToSelectedMap.get(curShipToId));
                            }
                        }
                    }
                }
            }
        }
        outMap.put('ACCOUNT', accountToSendList[0]);
        outMap.put('SALES_AREA', salesAreaToSendList);
        outMap.put('SALES_AREA_SHIP_TO', salesAreaToShipToMap);
        outMap.put('SHIP_TO', shipToMap);

        return outMap;
    }

    public void checkMandatoryFields(Map<String, Object> dataMap) {
        Account curAccount = (Account)dataMap.get('ACCOUNT');
        checkMandatoryField('Account.name', curAccount.name1__c);
        checkMandatoryField('Account.usertype', curAccount.User_Type__c);
        checkMandatoryField('Account.accountnumber', curAccount.Account_Number__c);
        checkMandatoryField('Account.billingcity', curAccount.BillingCity);
        checkMandatoryField('Account.billingcountry', curAccount.BillingCountryCode);
        checkMandatoryField('Account.billingstreet', curAccount.BillingStreet);
        checkMandatoryField('Account.languagecode', curAccount.Language_Code__c);
        checkMandatoryField('Account.accountgroup', curAccount.Account_Group__c);
        checkMandatoryField('Account.companycode', curAccount.Company_Code__c);
        checkMandatoryField('Account.reconciliationaccount', curAccount.Reconciliation_Account__c);

        List<Contact> curContactList = curAccount.Contacts;
        if(curContactList != null && curContactList.size()>0){
            for(Contact curContact : curContactList){
                checkMandatoryField('Contact.externid', curContact.ExternId__c);
                checkMandatoryField('Contact.email', curContact.Email);
            }
        }

        List<Sales_Area__c> curSalesAreaList = (List<Sales_Area__c>)dataMap.get('SALES_AREA');
        if(curSalesAreaList != null && curSalesAreaList.size()>0){
            for(Sales_Area__c curSalesArea : curSalesAreaList){
                checkMandatoryField('Sales_Area__c.externid', curSalesArea.ExternId__c);
                checkMandatoryField('Sales_Area__c.salesorganization', curSalesArea.Sales_Organization__c);
                checkMandatoryField('Sales_Area__c.distributionchannel', curSalesArea.Distribution_Channel__c);
                checkMandatoryField('Sales_Area__c.customergroup', curSalesArea.Customer_Group__c);
                checkMandatoryField('Sales_Area__c.salesareacurrency', curSalesArea.Currency__c);
                checkMandatoryField('Sales_Area__c.deliverypriority', curSalesArea.Delivery_Priority__c);
                checkMandatoryField('Sales_Area__c.shippingconditions', curSalesArea.Shipping_Conditions__c);
                checkMandatoryField('Sales_Area__c.shippingmethodcode', curSalesArea.Shipping_method_code__c);
                checkMandatoryField('Sales_Area__c.shippingmethoddescription', curSalesArea.Shipping_Method_Description__c);
                checkMandatoryField('Sales_Area__c.paymentagreement', curSalesArea.Payment_agreement__c);
                checkMandatoryField('Sales_Area__c.taxclassificationvat', curSalesArea.Tax_Classification_VAT__c);
                checkMandatoryField('Sales_Area__c.taxclassificationvatexemption', curSalesArea.Tax_Classification_VAT_Exemption__c);
                //checkMandatoryField('Sales_Area__c.soldtoparty', );mandiamo se stesso
            }
        }

        Map<String, SalesAreaShipTo__c> salesAreaShipToMap = (Map<String, SalesAreaShipTo__c>)dataMap.get('SALES_AREA_SHIP_TO');
        if(salesAreaShipToMap!=null && salesAreaShipToMap.keySet()!=null && salesAreaShipToMap.keySet().size()>0){
            for(SalesAreaShipTo__c curSalesAreaShipTo : salesAreaShipToMap.values()){
                checkMandatoryField('SalesAreaShipTo__c.shippingconditions', curSalesAreaShipTo.Shipping_Conditions__c);
                checkMandatoryField('SalesAreaShipTo__c.shippingmethodcode', curSalesAreaShipTo.Shipping_method_code__c);
                checkMandatoryField('SalesAreaShipTo__c.shippingmethoddescription', curSalesAreaShipTo.Shipping_Method_Description__c);
            }
        }

        Map<String, List<Ship_To__c>> shipToMap = (Map<String, List<Ship_To__c>>)dataMap.get('SHIP_TO');
        if(shipToMap!=null && shipToMap.keySet()!=null && shipToMap.keySet().size()>0){
            for(List<Ship_To__c> curShipToList : shipToMap.values()){
                for(Ship_To__c curShipTo : curShipToList){
                    checkMandatoryField('Ship_To__c.externid', curShipTo.ExternId__c);
                    checkMandatoryField('Ship_To__c.shiptonumber', curShipTo.Ship_To_Number__c);
                    checkMandatoryField('Ship_To__c.name', curShipTo.name1__c);
                    checkMandatoryField('Ship_To__c.addresscountrycode', curShipTo.Address__CountryCode__s);
                    checkMandatoryField('Ship_To__c.addresscity', curShipTo.Address__City__s);
                    checkMandatoryField('Ship_To__c.addressstreet', curShipTo.Address__Street__s);
                    //checkMandatoryField('Ship_To__c.vatnumber', curShipTo.VAT_Number__c);
                    //checkMandatoryField('Ship_To__c.shippingconditions', curShipTo.Shipping_Conditions__c);
                    //checkMandatoryField('Ship_To__c.shippingmethodcode', curShipTo.Shipping_method_code__c);
                    //checkMandatoryField('Ship_To__c.shippingmethoddescription', curShipTo.Shipping_Method_Description__c);
                    //checkMandatoryField('Ship_To__c.taxclassificationvatexemption', curShipTo.Tax_Classification_VAT_Exemption__c);
                    curContactList = curShipTo.Contacts__r;
                    if(curContactList != null && curContactList.size()>0){
                        for(Contact curContact : curContactList){
                            checkMandatoryField('Contact.externid', curContact.ExternId__c);
                            checkMandatoryField('Contact.email', curContact.Email);
                        }
                    }
                }
            }   

        }

    }

    public void checkMandatoryField(String fieldName, Object fieldValue) {

        if(fieldValue == null){
            throw new AccountCreateServiceException('Mandatory field ['+fieldName+'] not set');
        }

        if((fieldValue instanceof String) && String.isBlank((String)fieldValue)){
            throw new AccountCreateServiceException('Mandatory field ['+fieldName+'] not set');
        }
    }

    public String buildRequest(Map<String, Object> dataMap) {
        String jsonRequest;

        AccountBean curAccountBean = new AccountBean();
        Account curAccount = (Account)dataMap.get('ACCOUNT');
        List<Sales_Area__c> curSalesAreaList = (List<Sales_Area__c>)dataMap.get('SALES_AREA');
        Map<String, List<Ship_To__c>> shipToMap = (Map<String, List<Ship_To__c>>)dataMap.get('SHIP_TO');
        Map<String, SalesAreaShipTo__c> curSalesAreaShipToMap = (Map<String, SalesAreaShipTo__c>)dataMap.get('SALES_AREA_SHIP_TO');

        RequestBean curRequestBean = new RequestBean();
        curRequestBean.timestamp = ''+Datetime.now();
        curRequestBean.environment = Common_Settings__mdt.getInstance('ENVIRONMENT').SettingValue__c;
        curRequestBean.integrationflow = INTEGRATION_FLOW;
        curRequestBean.Account = curAccountBean;

        //BUILDING ACCOUNT
        curAccountBean.name = curAccount.name1__c;
        curAccountBean.name2 = curAccount.name2__c;
        curAccountBean.name3 = curAccount.name3__c;
        curAccountBean.name4 = curAccount.name4__c;
        curAccountBean.fiscalCode = curAccount.Fiscal_Code__c;
        curAccountBean.vatnumber = curAccount.VAT_Number__c;
        curAccountBean.vatregno = curAccount.VAT_Reg_No__c;
        curAccountBean.isnaturalperson = curAccount.isNatural_Person__c;
        curAccountBean.phone = curAccount.Phone;
        curAccountBean.fax = curAccount.Fax;
        curAccountBean.usertype = (String)transcodeValue('usertype', curAccount.User_Type__c);
        curAccountBean.einvoicingcertifiedemail = curAccount.E_Invoicing_Certified_Email__c;
        curAccountBean.interchangesystemsdi = curAccount.Interchange_System_SDI__c;
        curAccountBean.einvoicingtype = curAccount.E_Invoicing_Type__c;
        curAccountBean.accountnumber = curAccount.Account_Number__c;
        curAccountBean.billingcity = curAccount.BillingCity;
        curAccountBean.billingcountry = curAccount.BillingCountryCode;
        curAccountBean.billingpostalCode = curAccount.BillingPostalCode;
        curAccountBean.billingstate = curAccount.BillingStateCode;
        curAccountBean.billingstreet = curAccount.BillingStreet;
        curAccountBean.termsofpayment = curAccount.Terms_of_payment__c;
        curAccountBean.iban = curAccount.Iban__c;
        curAccountBean.languagecode = curAccount.Language_Code__c;
        curAccountBean.transportarea = curAccount.Transport_Area__c;
        curAccountBean.internalbank = curAccount.Internal_Bank__c;
        curAccountBean.accountbalance = curAccount.Account_Balance__c;
        curAccountBean.accountgroup = curAccount.Account_Group__c;
        curAccountBean.companycode = curAccount.Company_Code__c;
        curAccountBean.reconciliationaccount = curAccount.Reconciliation_Account__c;
        curAccountBean.sortkey = curAccount.Sort_Key__c;
        curAccountBean.logincode = curAccount.login_code__c;
        curAccountBean.mobilephone = curAccount.mobile_phone__c;
        curAccountBean.is_branch_office = curAccount.isBranchOffice__c;
        curAccountBean.attribute_1 = curAccount.tech_invoice_attr1__c;
        curAccountBean.attribute_2 = curAccount.tech_invoice_attr2__c;
        curAccountBean.electronic_signature = curAccount.electronic_signature__c;
        curAccountBean.sortfield = curAccount.Search_concept__c;
        curAccountBean.interno_phone = curAccount.interno_phone__c;
        curAccountBean.interno_fax = curAccount.interno_fax__c;

        curAccountBean.contact = buildContactList(curAccount.Contacts);
        curAccountBean.salesarea = buildSalesAreaList(curAccount, curSalesAreaList, shipToMap, curSalesAreaShipToMap);

        return Json.serialize(curRequestBean);
    }

    public Map<String, Object> sendRequest(String jsonRequest) {
        
        System.debug('sendRequest jsonRequest['+jsonRequest+']');

        Map<String, Object> responseMap = MSCallout.callGenericService(INTEGRATION_FLOW, jsonRequest, this.accountId);

        return responseMap;
    }

    public void manageResponse(Map<String, Object> responseMap) {

        String curStatusCode;

        Account accountToUpdate = new Account(
            Id = this.accountId
        );

        if(responseMap.containsKey('RESPONSE_STATUS_CODE')){
            curStatusCode = (String)responseMap.get('RESPONSE_STATUS_CODE');
        }
        
        if('200'.equalsIgnoreCase(curStatusCode) || '201'.equalsIgnoreCase(curStatusCode)){
            accountToUpdate.Account_Integration_Status__c = Constants.INTEGRATION_STATUS_OK;
            accountToUpdate.Account_Status__c = Constants.ACCOUNT_STATUS_ACTIVE;
            accountToUpdate.Account_Integration_Status_Description__c = 'SUCCESS';
        } else {
            accountToUpdate.Account_Integration_Status__c = Constants.INTEGRATION_STATUS_KO;
            String statusDescription;
            if(responseMap.containsKey('EXCEPTION')){
                Exception curException = (Exception)responseMap.get('EXCEPTION');
                statusDescription = curException.getMessage() + ' ' + curException.getStackTraceString();
            } else if(responseMap.containsKey('RESPONSE_STATUS')){
                statusDescription = (String)responseMap.get('RESPONSE_STATUS');
            }

            if(!String.isBlank(statusDescription) && statusDescription.length()>250){
                statusDescription = statusDescription.substring(0, 250);
            }
            accountToUpdate.Account_Integration_Status_Description__c = statusDescription;
        }

        update accountToUpdate;
    }

    private List<ContactBean> buildContactList(List<Contact> curContactList){
        List<ContactBean> outContactList = new List<ContactBean>();
        if(curContactList != null && curContactList.size()>0){
            for(Contact curContact : curContactList){
                outContactList.add(buildContact(curContact));
            }
        }
        return outContactList;
    }

    private ContactBean buildContact(Contact curContact){
        ContactBean curContactBean = new ContactBean();
        curContactBean.externid = curContact.ExternId__c;
        curContactBean.flg_nouse = curContact.FLG_NOUSE__c;
        curContactBean.flgdefault = curContact.flg_default__c;
        curContactBean.email = curContact.Email;
        curContactBean.emailtype = curContact.Email_Type__c;
        return curContactBean;
    }

    private List<SalesAreaBean> buildSalesAreaList(Account curAccount, List<Sales_Area__c> curSalesAreaList, Map<String, List<Ship_To__c>> shipToMap, Map<String, SalesAreaShipTo__c> curSalesAreaShipToMap){
        List<SalesAreaBean> outSalesAreaList = new List<SalesAreaBean>();
        if(curSalesAreaList != null && curSalesAreaList.size()>0){
            for(Sales_Area__c curSalesArea : curSalesAreaList){
                List<Ship_To__c> curShipToList = null;
                if(shipToMap.containsKey(curSalesArea.Id)){
                    curShipToList = shipToMap.get(curSalesArea.Id);
                }
                outSalesAreaList.add(buildSalesArea(curAccount, curSalesArea, curShipToList, curSalesAreaShipToMap));
            }
        }
        return outSalesAreaList;
    }

    private SalesAreaBean buildSalesArea(Account curAccount, Sales_Area__c curSalesArea, List<Ship_To__c> shipToList, Map<String, SalesAreaShipTo__c> curSalesAreaShipToMap){

        SalesAreaBean curSalesAreaBean = new SalesAreaBean();
        curSalesAreaBean.externid = curSalesArea.ExternId__c;
        curSalesAreaBean.paymentagreement = curSalesArea.Payment_agreement__c;
        curSalesAreaBean.salesorganization = curSalesArea.Sales_Organization__c;
        curSalesAreaBean.distributionchannel = curSalesArea.Distribution_Channel__c;
        curSalesAreaBean.customergroup = curSalesArea.Customer_Group__c;
        curSalesAreaBean.shippingmethodcode = curSalesArea.Shipping_method_code__c;
        curSalesAreaBean.warehouse = curSalesArea.Warehouse__c;
        curSalesAreaBean.distributionarea = curSalesArea.Distribution_Area__c;
        curSalesAreaBean.salesoffice = curSalesArea.Sales_Office__c;
        curSalesAreaBean.salesteam = curSalesArea.Sales_Team__c;
        curSalesAreaBean.maxpartialdelivery = curSalesArea.Max_Partial_Delivery__c;
        curSalesAreaBean.billingcalendar = curSalesArea.Billing_Calendar__c;
        curSalesAreaBean.bonus = curSalesArea.Bonus__c;
        curSalesAreaBean.creditctrlarea = curSalesArea.Credit_ctrl_area__c;
        curSalesAreaBean.salesareacurrency = curSalesArea.Currency__c;
        curSalesAreaBean.shippingconditions = curSalesArea.Shipping_Conditions__c;
        curSalesAreaBean.shippingmethoddescription = curSalesArea.Shipping_Method_Description__c;
        curSalesAreaBean.accountassignmentgroup = curSalesArea.Account_Assignment_Group__c;
        curSalesAreaBean.taxclassificationvat = curSalesArea.Tax_Classification_VAT__c;
        curSalesAreaBean.taxclassificationvatexemption = curSalesArea.Tax_Classification_VAT_Exemption__c;
        curSalesAreaBean.custpricproc = curSalesArea.Cust_Pric_Proc__c;
        curSalesAreaBean.custstatsgrp = curSalesArea.Cust_Stats_Grp__c;
        curSalesAreaBean.servicetype = curSalesArea.Service_Type__c;
        curSalesAreaBean.deliverypriority = curSalesArea.Delivery_Priority__c;
        curSalesAreaBean.soldtoparty = curAccount.account_number__c;//mandare se stesso
        curSalesAreaBean.ordersbundle = curSalesArea.Orders_Bundle__c;
        curSalesAreaBean.servicemanager = curSalesArea.Service_Manager__c;
        curSalesAreaBean.merge_invoices = curSalesArea.merge_invoices__c;
        if(curSalesArea.Payer_Accounts__r!= null && curSalesArea.Payer_Accounts__r.size() > 0){
            for(Payer_Account__c curPayerAccount : curSalesArea.Payer_Accounts__r){
                if('Payer'.equalsIgnoreCase(curPayerAccount.Type__c)){
                    curSalesAreaBean.payer = curPayerAccount.Code__c;
                } else if('BillToParty'.equalsIgnoreCase(curPayerAccount.Type__c)){
                    curSalesAreaBean.billtoparty = curPayerAccount.Code__c;
                }
            }
        }
        curSalesAreaBean.shipto = buildShipToList(curSalesArea.Id, shipToList, curSalesAreaShipToMap);

        return curSalesAreaBean;
    }


    private List<ShipToBean> buildShipToList(String curSalesAreaId, List<Ship_To__c> curShipToList, Map<String, SalesAreaShipTo__c> curSalesAreaShipToMap){
        List<ShipToBean> outShipToList = new List<ShipToBean>();
        if(curShipToList != null && curShipToList.size()>0){
            for(Ship_To__c curShipTo : curShipToList){
                SalesAreaShipTo__c curShipToSalesArea = curSalesAreaShipToMap.get(curSalesAreaId+'|'+curShipTo.Id);
                outShipToList.add(buildShipTo(curShipTo, curShipToSalesArea));
            }
        }
        return outShipToList;
    }

    private ShipToBean buildShipTo(Ship_To__c curShipTo, SalesAreaShipTo__c curShipToSalesArea){

        ShipToBean curShipToBean = new ShipToBean();
        curShipToBean.externid = curShipTo.ExternId__c;
        curShipToBean.shipTonumber = curShipTo.Ship_To_Number__c;
        curShipToBean.taxclassificationvat = curShipTo.Tax_Classification_VAT__c;
        curShipToBean.taxclassificationvatexemption = curShipTo.Tax_Classification_VAT_Exemption__c;
        curShipToBean.vatnumber = curShipTo.VAT_Number__c;
        curShipToBean.name = curShipTo.name1__c;
        curShipToBean.name2 = curShipTo.name2__c;
        curShipToBean.name3 = curShipTo.name3__c;
        curShipToBean.name4 = curShipTo.name4__c;
        curShipToBean.addresscity = curShipTo.Address__City__s;
        curShipToBean.addresscountrycode = curShipTo.Address__CountryCode__s;
        curShipToBean.addresspostalcode = curShipTo.Address__PostalCode__s;
        curShipToBean.addressstatecode = curShipTo.Address__StateCode__s;
        curShipToBean.addressstreet = curShipTo.Address__Street__s;
        curShipToBean.transportarea = curShipTo.Transport_Area__c;
        curShipToBean.warehouse = curShipToSalesArea.Warehouse__c;
        curShipToBean.servicetype = curShipToSalesArea.Service_Type__c;
        curShipToBean.ordersbundle = curShipToSalesArea.Orders_Bundle__c;
        curShipToBean.shippingconditions = curShipToSalesArea.Shipping_Conditions__c;
        curShipToBean.shippingmethoddescription = curShipToSalesArea.Shipping_Method_Description__c;
        curShipToBean.shippingmethodcode = curShipToSalesArea.Shipping_method_code__c;
        curShipToBean.servicemanager = curShipToSalesArea.Service_Manager__c;
        curShipToBean.contact = buildContactList(curShipTo.Contacts__r);

        return curShipToBean;
    }

    public Object transcodeValue(String curFieldName, String curValue){
        Object outValue = null;
        if('usertype'.equalsIgnoreCase(curFieldName)){
            switch on curValue{
                when 'Distributor' {outValue = 'DI';}
                when 'Wholesaler' {outValue = 'RI';}
                when 'Private User' {outValue = 'PR';}
                when 'Workshop' {outValue = 'W1';}
                when 'Bodyshop' {outValue = 'W2';}
                when 'Other' {outValue = 'OT';}
                when 'Fleet' {outValue = 'FL';}
                when 'Consortium' {outValue = 'C1';}
                when 'Commercial Group' {outValue = 'G2';}
                when 'Professional School' {outValue = 'SP';}
                when 'Satellite' {outValue = 'SA';}
                when 'Standard B2B/B2C' {outValue = 'YY';}
                when 'Export' {outValue = 'EX';}
                when 'Generic Workshop' {outValue = 'W4';}
                when 'Constructor' {outValue = 'CO';}
                when 'Stellantis' {outValue = 'ST';}
                when 'Online Training' {outValue = 'TO';}
                when 'Ecommerce' {outValue = 'EC';}
                when else { outValue = curValue; }
            }
        } else {
            outValue = curValue;
        }
        return outValue;
    }

    public class AccountCreateServiceException extends Exception {}

    public class RequestBean{
        String timestamp;
        String environment;
        String integrationflow;
        AccountBean account;
    }

    public class AccountBean{
        String name;
        String name2;
        String name3;
        String name4;
        String fiscalcode;
        String vatnumber;
        String vatregno;
        Boolean isnaturalperson;
        String phone;
        String fax;
        String usertype;
        String einvoicingcertifiedemail;
        String interchangesystemsdi;
        String einvoicingtype;
        String accountnumber;
        String billingcity;
        String billingcountry;
        String billingpostalcode;
        String billingstate;
        String billingstreet;
        String termsofpayment;
        String iban;
        String languagecode;
        String transportarea;
        String internalbank;
        String accountbalance;
        String accountgroup;
        String companycode;
        String reconciliationaccount;
        String sortkey;
        String logincode;
        String newreferenceaccountsap;
        String mobilephone;
        String attribute_1;
        String attribute_2;
        String electronic_signature;
        String sortfield;
        String interno_phone;
        String interno_fax;
        Boolean is_branch_office;
        List<ContactBean> contact;
        List<SalesAreaBean> salesarea;
    }

    public class ContactBean{
        Boolean flg_nouse;
        Boolean flgdefault;
        String externid;
        String email;
        String emailtype;
    }

    public class SalesAreaBean{
        String externid;
        String paymentagreement;
        String salesorganization;
        String distributionchannel;
        String customergroup;
        String shippingmethodcode;
        String warehouse;
        String distributionarea;
        String salesoffice;
        String salesteam;
        String maxpartialdelivery;
        String billingcalendar;
        Boolean bonus;
        String creditctrlarea;
        String salesareacurrency;
        String shippingconditions;
        String shippingmethoddescription;
        String accountassignmentgroup;
        String taxclassificationvat;
        String taxclassificationvatexemption;
        String custpricproc;
        String custstatsgrp;
        String servicetype;
        String deliverypriority;
        String soldtoparty;
        Boolean ordersbundle;
        String servicemanager;
        String payer;
        String billtoparty;
        String merge_invoices;
        List<ShipToBean> shipto;
    }

   
    public class ShipToBean{
        String externid;
        String shiptonumber;
        String taxclassificationvat;
        String taxclassificationvatexemption;
        String vatnumber;
        String name;
        String name2;
        String name3;
        String name4;
        String addresscity;
        String addresscountrycode;
        String addresspostalcode;
        String addressstatecode;
        String addressstreet;
        String transportarea;
        String warehouse;
        String servicetype;
        Boolean ordersbundle;
        String shippingconditions;
        String shippingmethoddescription;
        String shippingmethodcode;
        String servicemanager;
        List<ContactBean> contact;
    }

}
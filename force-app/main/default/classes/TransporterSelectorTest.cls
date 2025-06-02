@isTest
private class TransporterSelectorTest {
    @isTest static void testGetTransportOptions_withValidOrder() {
        Account acc = new Account(Name = 'Test Account', Type_of_client__c = 'Professionnel');
        insert acc;

        Order ord = new Order(
            AccountId = acc.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            ShippingCountry = 'France'
        );
        insert ord;

        Transporter__c transporter1 = new Transporter__c(Name = 'Chronopost');
        insert transporter1;

        Transporter__c transporter2 = new Transporter__c(Name = 'DHL');
        insert transporter2;

        TransporterRate__c rate1 = new TransporterRate__c(
            Transporter__c = transporter1.Id,
            Delivery_Price__c = 10.50,
            Delivery_Time__c = 48,
            Country__c = 'France',
            Clients_Type__c = 'Professionnel' // Valeur compatible avec acc.Type_of_client__c
        );
        insert rate1;

        TransporterRate__c rate2 = new TransporterRate__c(
            Transporter__c = transporter2.Id,
            Delivery_Price__c = 20.00,
            Delivery_Time__c = 24,
            Country__c = 'France',
            Clients_Type__c = 'Both'
        );
        insert rate2;

        Test.startTest();
        List<TransporterSelector.TransporterOption> options = TransporterSelector.getTransportOptions(ord.Id);
        Test.stopTest();

        System.assertNotEquals(null, options);
        System.assert(options.size() > 0);

        Boolean hasCheapest = false;
        Boolean hasFastest = false;

        for (TransporterSelector.TransporterOption option : options) {
            System.assertNotEquals(null, option.value);
            System.assertNotEquals(null, option.transporterId);
            System.assertNotEquals(null, option.price);
            System.assertNotEquals(null, option.deliveryDays);
            System.assertNotEquals(null, option.transporterName);
            System.assertNotEquals(null, option.label);

            if (option.value == 'cheapest') hasCheapest = true;
            if (option.value == 'fastest') hasFastest = true;
        }

        System.assert(hasCheapest, 'Doit contenir une option "cheapest"');
        System.assert(hasFastest, 'Doit contenir une option "fastest"');
    }

    @isTest static void testGetTransportOptions_withNullOrderId() {
        List<TransporterSelector.TransporterOption> options = TransporterSelector.getTransportOptions(null);
        System.assertEquals(0, options.size());
    }

    @isTest static void testGetTransportOptions_withInvalidOrderId() {
        Id fakeId = '801000000000000AAA';
        List<TransporterSelector.TransporterOption> options = TransporterSelector.getTransportOptions(fakeId);
        System.assertEquals(0, options.size());
    }
}
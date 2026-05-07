@AccessControl.authorizationCheck: #CHECK

@EndUserText.label: '###GENERATED Core Data Service Entity'

@Metadata.allowExtensions: true

define root view entity ZC_MM_PROG_PAY
  provider contract transactional_query
  as projection on ZR_MM_PROG_PAY

{
  key Transportdocno,

      @ObjectModel.text.element: [ 'SupplierName' ]
      Supplier,

      @ObjectModel.text.element: [ 'ProductName' ]
      Product,

      @ObjectModel.text.element: [ 'CustomerName' ]
      Customer,

      TransportationCreationDate,
      TransportationStartdate,
      TransportationEndDate,
      NumberOfTrips,
      TotalKm,
      SpotPaymentPrice,
      SpotFuelAmount,

      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_CurrencyStdVH', element: 'Currency' },
                                            useForValidation: true } ]
      @Semantics.currencyCode: true
      Currency,

      DepartureProvince,
      DepartureDistrict,
      DeparturePoint,
      ArrivalProvince,
      ArrivalDistrict,
      ArrivalPoint,
      HeatRegimeType,
      OperationType,
      IsDeleted,

      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      @Semantics.text: true
      _Supplier.SupplierName,

      @Semantics.text: true
      _Product._Text.ProductName : localized,

      @Semantics.text: true
      _Customer.CustomerName
}

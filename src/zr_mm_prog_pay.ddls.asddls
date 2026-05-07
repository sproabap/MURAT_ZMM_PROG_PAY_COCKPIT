@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: '###GENERATED Core Data Service Entity'

@Metadata.allowExtensions: true

define root view entity ZR_MM_PROG_PAY
  as select from zmm_prog_pay as ProgressPayment
  association [0..1] to I_Supplier as _Supplier on $projection.Supplier = _Supplier.Supplier
  association [0..1] to I_Product  as _Product  on $projection.Product = _Product.Product
  association [0..1] to I_Customer as _Customer on $projection.Customer = _Customer.Customer

{
  key transportdocno            as Transportdocno,

      supplier                  as Supplier,
      product                   as Product,
      customer                  as Customer,
      transportdoc_creationdate as TransportationCreationDate,
      transportation_startdate  as TransportationStartdate,
      transportation_enddate    as TransportationEndDate,
      number_of_trips           as NumberOfTrips,
      total_km                  as TotalKm,

      @Semantics.amount.currencyCode: 'Currency'
      spot_payment_price        as SpotPaymentPrice,

      @Semantics.amount.currencyCode: 'Currency'
      spot_fuel_amount          as SpotFuelAmount,

      currency                  as Currency,
      departure_province        as DepartureProvince,
      departure_district        as DepartureDistrict,
      departure_point           as DeparturePoint,
      arrival_province          as ArrivalProvince,
      arrival_district          as ArrivalDistrict,
      arrival_point             as ArrivalPoint,
      heat_regime_type          as HeatRegimeType,
      operation_type            as OperationType,
      is_deleted                as IsDeleted,

      @Semantics.user.createdBy: true
      created_by                as CreatedBy,

      @Semantics.systemDateTime.createdAt: true
      created_at                as CreatedAt,

      @Semantics.user.lastChangedBy: true
      last_changed_by           as LastChangedBy,

      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at           as LastChangedAt,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at     as LocalLastChangedAt,

      _Supplier,
      _Product,
      _Customer
}

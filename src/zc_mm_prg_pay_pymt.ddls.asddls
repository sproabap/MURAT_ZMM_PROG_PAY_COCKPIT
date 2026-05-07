@AccessControl.authorizationCheck: #CHECK

@EndUserText.label: '###GENERATED Core Data Service Entity'

@Metadata.allowExtensions: true

define root view entity ZC_MM_PRG_PAY_PYMT
  provider contract transactional_query
  as projection on ZR_MM_PRG_PAY_PYMT

{
  key Calendaryear,
  key Calendarmonth,
  key Supplier,
  key Product,
  key Customer,
  key PurchasingOrganization,

      PaymentMade,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}

@AccessControl.authorizationCheck: #CHECK

@EndUserText.label: '###GENERATED Core Data Service Entity'

@Metadata.allowExtensions: true

define root view entity ZC_MM_PRG_PAY_DAYS
  provider contract transactional_query
  as projection on ZR_MM_PRG_PAY_DAYS

{
  key CalendarYear,
  key CalendarMonth,
  key Supplier,
  key Product,
  key Customer,
  key PurchasingOrganization,

      ActualDays,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}

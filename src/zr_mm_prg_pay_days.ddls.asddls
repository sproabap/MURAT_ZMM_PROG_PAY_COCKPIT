@AccessControl.authorizationCheck: #CHECK

@EndUserText.label: '###GENERATED Core Data Service Entity'

@Metadata.allowExtensions: true

define root view entity ZR_MM_PRG_PAY_DAYS
  as select from zmm_prg_pay_days as ProgPayActualDays

{
  key calendar_year          as CalendarYear,
  key calendar_month         as CalendarMonth,
  key supplier               as Supplier,
  key product                as Product,
  key customer               as Customer,
  key purchasingorganization as PurchasingOrganization,

      actual_days            as ActualDays,

      @Semantics.user.createdBy: true
      created_by             as CreatedBy,

      @Semantics.systemDateTime.createdAt: true
      created_at             as CreatedAt,

      @Semantics.user.lastChangedBy: true
      last_changed_by        as LastChangedBy,

      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at        as LastChangedAt,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at  as LocalLastChangedAt
}

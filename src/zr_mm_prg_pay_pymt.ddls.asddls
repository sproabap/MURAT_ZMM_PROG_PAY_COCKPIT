@AccessControl.authorizationCheck: #CHECK

@EndUserText.label: '###GENERATED Core Data Service Entity'

@Metadata.allowExtensions: true

define root view entity ZR_MM_PRG_PAY_PYMT
  as select from zmm_prg_pay_pymt as ProgressPaymentSpotPayment

{
  key calendaryear           as Calendaryear,
  key calendarmonth          as Calendarmonth,
  key supplier               as Supplier,
  key product                as Product,
  key customer               as Customer,
  key purchasingorganization as PurchasingOrganization,

      payment_made           as PaymentMade,

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

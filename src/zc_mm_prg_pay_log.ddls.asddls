@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_MM_PRG_PAY_LOG
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_MM_PRG_PAY_LOG
{
  key Transportdocno,
  key PaymentUuid,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt
  
}

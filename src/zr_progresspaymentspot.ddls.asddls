@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Progress Payment Spot'

@Metadata.ignorePropagatedAnnotations: true

define root view entity ZR_ProgressPaymentSpot
  as select from    ZR_ProgressPayment as ProgressPayment

    //    left outer join ZR_MM_PRG_PAY_PYMT as Payment
    //      on  Payment.Calendaryear           = ProgressPayment.CalendarYear
    //      and Payment.Calendarmonth          = ProgressPayment.CalendarMonth
    //      and Payment.Supplier               = ProgressPayment.Supplier
    //      and Payment.Product                = ProgressPayment.Product
    //      and Payment.Customer               = ProgressPayment.Customer
    //      and Payment.PurchasingOrganization = ProgressPayment.PurchasingOrganization
    left outer join I_JournalEntry     as JournalEntry    on  JournalEntry.DocumentReferenceID     = ProgressPayment.PurchaseOrder
                                                          and JournalEntry.ReverseDocument        is initial
                                                          and JournalEntry.AccountingDocumentType  = 'KZ'
//    left outer join I_SuplrInvcItemPurOrdRefAPI01 as SupplierInvoice on SupplierInvoice.PurchaseOrder = ProgressPayment.PurchaseOrder

  association [0..1] to ZI_MMVEHICLECATEGORY as _VehicleCategory on _VehicleCategory.Vehiclecategory = $projection.VehicleCategory
  association [0..1] to ZI_MMVEHICLETYPE     as _VehicleType     on _VehicleType.VehicleType = $projection.VehicleType
  association [0..1] to ZI_MMVEHICLEBODY     as _VehicleBody     on _VehicleBody.Vehiclebody = $projection.VehicleBody

{
  key ProgressPayment.TransportDocNo,

      ProgressPayment.CalendarYear,
      ProgressPayment.CalendarMonth,
      ProgressPayment.Supplier,
      ProgressPayment.Product,
      ProgressPayment.Customer,
      ProgressPayment.PurchasingOrganization,

      @Semantics.amount.currencyCode: 'Currency'
      //      cast( sum( ProgressPayment.SpotPaymentPrice ) as zsd_spot_payment_price ) as SpotPaymentPrice,
      ProgressPayment.SpotPaymentPrice                           as SpotPaymentPrice,

      @Semantics.amount.currencyCode: 'Currency'
      //      cast( sum( ProgressPayment.SpotFuelAmount ) as zmm_spot_fuel_amount )     as SpotFuelAmount,
      ProgressPayment.SpotFuelAmount                             as SpotFuelAmount,

      @Semantics.amount.currencyCode: 'Currency'
      //      cast( sum( ProgressPayment.SpotPaymentPrice ) as zmm_total_price )        as TotalPrice,
      cast(ProgressPayment.SpotPaymentPrice  as zmm_total_price) as TotalPrice,

      ProgressPayment.Currency,
      ProgressPayment.OperationType,

//      ProgressPayment._Product.YY1_VehicleCategory_PRD             as VehicleCategory,
      ProgressPayment._VehicleCategoryPurhasing.VehicleCategory  as VehicleCategory,
      ProgressPayment._Product.YY1_MMVehicleType_PRD             as VehicleType,
      ProgressPayment._Product.YY1_VehicleBody_PRD               as VehicleBody,
      ProgressPayment._Product.YY1_VehicleCapacity_PRD           as VehicleCapacity,

      ProgressPayment._Product,
      ProgressPayment._Supplier,
      ProgressPayment._Customer,
      ProgressPayment._DistributionChannel,
      ProgressPayment._PurchasingOrganization,

      ProgressPayment.PurchaseOrder,
//      SupplierInvoice._SupplierInvoiceAPI01.SupplierInvoiceIDByInvcgParty as SupplierInvoiceReference,
      ProgressPayment.SupplierInvoiceReference,
      ProgressPayment.PurchasingHistoryDocument,

      cast(case
            when ProgressPayment.SpotFuelAmount is initial then 'X'
            when JournalEntry.DocumentReferenceID is null then ' '
            when JournalEntry.DocumentReferenceID is not null and JournalEntry.DocumentReferenceID is not initial then'X'
            else ' '
           end as zmm_payment_made preserving type)              as PaymentMade,

      cast(case
            when ProgressPayment.PurchaseOrder is null then ' '
            when ProgressPayment.PurchaseOrder is not null and ProgressPayment.PurchaseOrder is not initial then 'X'
            else ' '
           end as abap_boolean preserving type)                  as POFilter,

      ProgressPayment._SupplierTaxNumber[BPTaxType = 'TR2'].BPTaxNumber,
      _VehicleCategory,
      _VehicleType,
      _VehicleBody
}
 
where ProgressPayment.IsDeleted is initial
  //  and ProgressPayment._Product.YY1_VehicleCategory_PRD  = '03'
  and ProgressPayment._VehicleCategoryPurhasing.VehicleCategory  = '03'

//group by ProgressPayment.CalendarYear,
//         ProgressPayment.CalendarMonth,
//         ProgressPayment.Supplier,
//         ProgressPayment.Product,
//         ProgressPayment.Customer,
//         ProgressPayment.Currency,
//         ProgressPayment.OperationType,
//         ProgressPayment._Product.YY1_VehicleCategory_PRD,
//         ProgressPayment._Product.YY1_MMVehicleType_PRD,
//         ProgressPayment._Product.YY1_VehicleBody_PRD,
//         ProgressPayment._Product.YY1_VehicleCapacity_PRD,
//         ProgressPayment.PurchasingOrganization,
//         Payment.PaymentMade;

@AccessControl.authorizationCheck: #CHECK

@EndUserText.label: 'Progrees Payment Rental'

@Metadata.ignorePropagatedAnnotations: true

define root view entity ZR_ProgressPaymentRental
  as select from ZR_ProgressPayment     as ProgressPayment

  //    join         ZI_MmDefaultCustomer as DefaultCustomer on DefaultCustomer.Customer = DefaultCustomer.Customer
    inner join   I_Product              as Product             on Product.Product = ProgressPayment.Product

    inner join   ZI_VestingTypeMatching as VestingTypeMatching on VestingTypeMatching.Vestingmodel = Product.YY1_MMVestingModel_PRD
  //    left outer join I_SuplrInvcItemPurOrdRefAPI01 as SupplierInvoice on SupplierInvoice.PurchaseOrder = ProgressPayment.PurchaseOrder
  association [0..1] to ZI_MMVEHICLECATEGORY   as _VehicleCategory     on _VehicleCategory.Vehiclecategory = $projection.VehicleCategory
  association [0..1] to ZI_MMVEHICLETYPE       as _VehicleType         on _VehicleType.VehicleType = $projection.VehicleType
  association [0..1] to ZI_MMVEHICLEBODY       as _VehicleBody         on _VehicleBody.Vehiclebody = $projection.VehicleBody
  association [0..1] to ZI_MmVestingModel      as _VestingModel        on _VestingModel.Vestingmodel = $projection.VestingModel
  association [0..1] to ZR_MM_VESTDEDUCTS      as _VestingDeduction    on _VestingDeduction.Material = $projection.Product

  //  association [0..1] to I_DistributionChannel  as _DistributionChannel on _DistributionChannel.DistributionChannel = $projection.OperationType
  association [0..1] to ZI_VestingTypeMatching as _VestingTypeMatching on _VestingTypeMatching.Vestingmodel = $projection.VestingModel
  //  association [0..1] to I_Customer             as _DefaultCustomer     on _DefaultCustomer.Customer = $projection.Customer

{
  key ProgressPayment.CalendarYear,
  key ProgressPayment.CalendarMonth,
  key ProgressPayment.Supplier,
  key ProgressPayment.Product,
  key ProgressPayment.Customer,
      //  key DefaultCustomer.Customer,
  key ProgressPayment.PurchasingOrganization,

      //      ProgressPayment._Product.YY1_VehicleCategory_PRD                             as VehicleCategory,
      ProgressPayment._VehicleCategoryPurhasing.VehicleCategory                                                                            as VehicleCategory,
      ProgressPayment._Product.YY1_MMVehicleType_PRD                                                                                       as VehicleType,
      ProgressPayment._Product.YY1_VehicleBody_PRD                                                                                         as VehicleBody,
      ProgressPayment._Product.YY1_VehicleCapacity_PRD                                                                                     as VehicleCapacity,
      cast(ProgressPayment._Product.YY1_MMVestingModel_PRD  as zmm_vestingmodel)                                                           as VestingModel,
      //      ProgressPayment.OperationType,

      //      cast( count( distinct ProgressPayment.TransportationStartDate ) as zmm_actual_days ) as ActualDays,
      //      cast(sum(ProgressPayment.NumberOfTrips) as zmm_actual_trip_count)          as ActualTripCount,
      cast(sum(case when ProgressPayment.Customer = '0000001028' or ProgressPayment._Customer.CustomerName = 'Araç Boş Geçiş Bölgesi' then 0 else ProgressPayment.NumberOfTrips end) as zmm_actual_trip_count) as ActualTripCount,
      cast(sum(ProgressPayment.TotalKM) as zmm_total_km)                                                                                   as ActualKM,

      ProgressPayment.Currency,


      ProgressPayment._Product,
      ProgressPayment._Supplier,
      ProgressPayment._Customer,
      ProgressPayment._PurchasingOrganization,
      //      _DefaultCustomer,

      ProgressPayment.PurchaseOrder,
      //      SupplierInvoice._SupplierInvoiceAPI01.SupplierInvoiceIDByInvcgParty as SupplierInvoiceReference,
      ProgressPayment.SupplierInvoiceReference,
      ProgressPayment.PurchasingHistoryDocument,

      cast(case
            when ProgressPayment.PurchaseOrder is null then ' '
            when ProgressPayment.PurchaseOrder is not null and ProgressPayment.PurchaseOrder is not initial then 'X'
            else ' '
           end as abap_boolean preserving type)                                                                                            as POFilter,
      @Semantics.amount.currencyCode: 'TotalBonusCurrency'
      ProgressPayment.TotalBonus,
      ProgressPayment.TotalBonusCurrency,
      @ObjectModel.text.element: [ 'BusinessPartnerName1' ]
      ProgressPayment.OperationRegion,
      ProgressPayment.DieselPercentage,
      ProgressPayment.BusinessPartnerName1,
      @Semantics.amount.currencyCode: 'TotalDeducamountC'
      ProgressPayment.TotalDeducamount,
      ProgressPayment.TotalDeducamountC,
      @Semantics.amount.currencyCode: 'Currency'
      ProgressPayment.AverageFuelAmountVehicle,

      _VehicleCategory,
      _VehicleType,
      _VehicleBody,
      _VestingModel,
      _VestingDeduction,
      //      _DistributionChannel,
      _VestingTypeMatching
}

where
      ProgressPayment.IsDeleted                                 is initial
  //  and (    ProgressPayment._Product.YY1_MMVestingModel_PRD = '01'
  //        or ProgressPayment._Product.YY1_MMVestingModel_PRD = '02'
  //        or ProgressPayment._Product.YY1_MMVestingModel_PRD = '04'
  //        or ProgressPayment._Product.YY1_MMVestingModel_PRD = '05'
  //        or ProgressPayment._Product.YY1_MMVestingModel_PRD = '06'
  //        or ProgressPayment._Product.YY1_MMVestingModel_PRD = '07' )
  // and _VestingTypeMatching.Vestingtype = 'R'
  and VestingTypeMatching.Vestingtype                           =  'R'
  and ProgressPayment._VehicleCategoryPurhasing.VehicleCategory <> '03'

group by
  ProgressPayment.CalendarYear,
  ProgressPayment.CalendarMonth,
  ProgressPayment.Supplier,
  ProgressPayment.Product,
  ProgressPayment.Customer,
  //         DefaultCustomer.Customer,
  //         ProgressPayment._Product.YY1_VehicleCategory_PRD,
  ProgressPayment._VehicleCategoryPurhasing.VehicleCategory,
  ProgressPayment._Product.YY1_MMVehicleType_PRD,
  ProgressPayment._Product.YY1_VehicleBody_PRD,
  ProgressPayment._Product.YY1_VehicleCapacity_PRD,
  ProgressPayment._Product.YY1_MMVestingModel_PRD,
  //         ProgressPayment.OperationType,
  ProgressPayment.Currency,
  ProgressPayment.PurchasingOrganization,
  ProgressPayment.PurchaseOrder,
  ProgressPayment.PurchasingHistoryDocument,
  //         SupplierInvoice._SupplierInvoiceAPI01.SupplierInvoiceIDByInvcgParty;
  ProgressPayment.SupplierInvoiceReference,
  ProgressPayment.TotalBonus,
  ProgressPayment.TotalBonusCurrency,
  ProgressPayment.OperationRegion,
  ProgressPayment.DieselPercentage,
  ProgressPayment.BusinessPartnerName1,
  ProgressPayment.TotalDeducamount,
  ProgressPayment.TotalDeducamountC,
  ProgressPayment.AverageFuelAmountVehicle;

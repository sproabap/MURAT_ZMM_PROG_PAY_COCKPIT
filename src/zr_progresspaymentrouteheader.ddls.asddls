@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Progress Payment Route Header'

@Metadata.ignorePropagatedAnnotations: true

define root view entity ZR_ProgressPaymentRouteHeader
  as select distinct from ZR_ProgressPayment     as ProgressPayment

    inner join            I_Product              as Product             on Product.Product = ProgressPayment.Product
    inner join            ZI_VestingTypeMatching as VestingTypeMatching on VestingTypeMatching.Vestingmodel = Product.YY1_MMVestingModel_PRD
  //    left outer join I_SuplrInvcItemPurOrdRefAPI01 as SupplierInvoice on SupplierInvoice.PurchaseOrder = ProgressPayment.PurchaseOrder

  association [0..1] to ZI_MMVEHICLECATEGORY        as _VehicleCategory on _VehicleCategory.Vehiclecategory = $projection.VehicleCategory
  association [0..1] to ZI_MMVEHICLETYPE            as _VehicleType     on _VehicleType.VehicleType = $projection.VehicleType
  association [0..1] to ZI_MMVEHICLEBODY            as _VehicleBody     on _VehicleBody.Vehiclebody = $projection.VehicleBody
  association [0..1] to ZI_MmVestingModel           as _VestingModel    on _VestingModel.Vestingmodel = $projection.VestingModel

  composition [0..*] of ZR_ProgressPaymentRouteItem as _Item

{
  key ProgressPayment.CalendarYear,
  key ProgressPayment.CalendarMonth,
  key ProgressPayment.Supplier,
  key ProgressPayment.Product,
  key ProgressPayment.Customer,
  key ProgressPayment.PurchasingOrganization,
      //  key ProgressPayment.DepartureProvince,
      //  key ProgressPayment.DepartureDistrict,
      //  key ProgressPayment.DeparturePoint,
      //  key ProgressPayment.ArrivalProvince,
      //  key ProgressPayment.ArrivalDistrict,
      //  key ProgressPayment.ArrivalPoint,
      //  key ProgressPayment.HeatRegimeType,

      //      ProgressPayment._Product.YY1_VehicleCategory_PRD as VehicleCategory,
      ProgressPayment._VehicleCategoryPurhasing.VehicleCategory as VehicleCategory,
      ProgressPayment._Product.YY1_MMVehicleType_PRD            as VehicleType,
      ProgressPayment._Product.YY1_VehicleBody_PRD              as VehicleBody,
      ProgressPayment._Product.YY1_VehicleCapacity_PRD          as VehicleCapacity,
      ProgressPayment._Product.YY1_MMVestingModel_PRD           as VestingModel,
      //      ProgressPayment.OperationType,
      ProgressPayment.Currency,

      ProgressPayment._Product,
      ProgressPayment._Supplier,
      ProgressPayment._Customer,
      ProgressPayment._PurchasingOrganization,

      ProgressPayment.PurchaseOrder,
      //      SupplierInvoice._SupplierInvoiceAPI01.SupplierInvoiceIDByInvcgParty as SupplierInvoiceReference,
      ProgressPayment.SupplierInvoiceReference,
      ProgressPayment.PurchasingHistoryDocument,

      cast(case
            when ProgressPayment.PurchaseOrder is null then ' '
            when ProgressPayment.PurchaseOrder is not null and ProgressPayment.PurchaseOrder is not initial then 'X'
            else ' '
           end as abap_boolean preserving type)                 as POFilter,
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
      //      ProgressPayment._DistributionChannel,

      _Item
}

where
      ProgressPayment.IsDeleted                                 is initial
  //  and ProgressPayment._Product.YY1_MMVestingModel_PRD = '03'
  and VestingTypeMatching.Vestingtype                           =  'T'
  and ProgressPayment._VehicleCategoryPurhasing.VehicleCategory <> '03'

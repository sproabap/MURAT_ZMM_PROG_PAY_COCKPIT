@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Progress Payment'

@Metadata.ignorePropagatedAnnotations: true

define root view entity ZR_ProgressPayment
  as select distinct from zmm_prog_pay                as ProgressPayment

    inner join            ZR_SD_T_SHIPPING            as Shipping        on Shipping.Transportdocno = ProgressPayment.transportdocno
    inner join            I_CalendarDate              as CalendarDate    on CalendarDate.CalendarDate = ProgressPayment.transportation_startdate
    left outer join       ZC_ProgressPayPurchaseOrder as PurchaseOrder   on PurchaseOrder.Transportdocno = ProgressPayment.transportdocno
    left outer join       I_SuplrInvcItemPurOrdRefAPI01 as SupplierInvoice on SupplierInvoice.PurchaseOrder = PurchaseOrder.PurchaseOrder
    left outer join       I_PurchaseOrderAPI01        as _PurchaseOrder on _PurchaseOrder.PurchaseOrder = PurchaseOrder.PurchaseOrder 
  //    left outer join       ZR_MM_VEHSUPPMATCH          as VehicleSupplier
  //      on  VehicleSupplier.Supplier = ProgressPayment.supplier
  //      and VehicleSupplier.Material = ProgressPayment.product
 
  association [0..1] to I_Supplier                  as _Supplier                 on _Supplier.Supplier = $projection.Supplier
  association [0..1] to I_Product                   as _Product                  on _Product.Product = $projection.Product
  association [0..1] to I_Customer                  as _Customer                 on _Customer.Customer = $projection.Customer
  association [0..1] to I_DistributionChannel       as _DistributionChannel      on _DistributionChannel.DistributionChannel = $projection.OperationType
  association [0..1] to I_PurchasingOrganization    as _PurchasingOrganization   on _PurchasingOrganization.PurchasingOrganization = $projection.PurchasingOrganization
  association [0..*] to I_Businesspartnertaxnumber  as _SupplierTaxNumber        on _SupplierTaxNumber.BusinessPartner = $projection.Supplier

  association [0..1] to ZI_VehicleCategoryPurhasing as _VehicleCategoryPurhasing on  _VehicleCategoryPurhasing.Product                = $projection.Product
                                                                                 and _VehicleCategoryPurhasing.PurchasingOrganization = $projection.PurchasingOrganization
  association [0..1] to ZI_FuelVesting as _FuelVesting on _FuelVesting.CalendarYear = $projection.CalendarYear
                                                      and _FuelVesting.CalendarMonth = $projection.CalendarMonth
                                                      and _FuelVesting.Product  = $projection.Product                                             
  
{
  key ProgressPayment.transportdocno           as TransportDocNo,

      ProgressPayment.supplier                 as Supplier,
      ProgressPayment.product                  as Product,

      //      case
      //       when ProgressPayment.customer is initial then VehicleSupplier.Customer
      //       else ProgressPayment.customer
      //      end                                      as Customer,
      ProgressPayment.customer                 as Customer,

      ProgressPayment.transportation_startdate as TransportationStartDate,
      ProgressPayment.number_of_trips          as NumberOfTrips,
      ProgressPayment.total_km                 as TotalKM,

      @Semantics.amount.currencyCode: 'Currency'
      ProgressPayment.spot_payment_price       as SpotPaymentPrice,

      @Semantics.amount.currencyCode: 'Currency'
      ProgressPayment.spot_fuel_amount         as SpotFuelAmount,

      ProgressPayment.currency                 as Currency,

      ProgressPayment.departure_province       as DepartureProvince,
      ProgressPayment.departure_district       as DepartureDistrict,
      ProgressPayment.departure_point          as DeparturePoint,

      ProgressPayment.arrival_province         as ArrivalProvince,
      ProgressPayment.arrival_district         as ArrivalDistrict,
      ProgressPayment.arrival_point            as ArrivalPoint,

      ProgressPayment.heat_regime_type         as HeatRegimeType,

      ProgressPayment.operation_type           as OperationType,

      ProgressPayment.is_deleted               as IsDeleted,

      CalendarDate.CalendarYear,
      CalendarDate.CalendarMonth,

      cast(case
            when Shipping.PurchasingOrganization is not initial then Shipping.PurchasingOrganization
            else '1010'
           end as ekorg preserving type)       as PurchasingOrganization,

      PurchaseOrder.PurchaseOrder,
//      SupplierInvoice._SupplierInvoiceAPI01.SupplierInvoiceIDByInvcgParty as SupplierInvoiceReference,
      PurchaseOrder.SupplierInvoiceIDByInvcgParty as SupplierInvoiceReference,
      PurchaseOrder.PurchasingHistoryDocument,

      ProgressPayment.created_by               as CreatedBy,
      ProgressPayment.created_at               as CreatedAt,
      ProgressPayment.last_changed_by          as LastChangedBy,
      ProgressPayment.last_changed_at          as LastChangedAt,
      ProgressPayment.local_last_changed_at    as LocalLastChangedAt,
      @Semantics.amount.currencyCode: 'TotalBonusCurrency'
      _PurchaseOrder.YY1_TotalBonusAmount_PDH  as TotalBonus,
      _PurchaseOrder.YY1_TotalBonusAmount_PDHC as TotalBonusCurrency,
      _Product.YY1_DieselPercentage_PRD as DieselPercentage,
      _Product.YY1_operationRegion_PRD as OperationRegion,
      _Product._YY1_operationRegion_PRD.BusinessPartnerName1,
      @Semantics.amount.currencyCode: 'TotalDeducamountC'
      _PurchaseOrder.YY1_TotalDeductionAmnt_PDH as TotalDeducamount,
      _PurchaseOrder.YY1_TotalDeductionAmnt_PDHC as TotalDeducamountC,
       @Semantics.amount.currencyCode: 'Currency'
      _FuelVesting.AverageFuelAmountVehicle,
      
      _Supplier,
      _Product,
      _Customer,
      _DistributionChannel,
      _PurchasingOrganization,
      _SupplierTaxNumber,
      _VehicleCategoryPurhasing,
      _FuelVesting
}

//where PurchaseOrder.PurchaseOrder is null;

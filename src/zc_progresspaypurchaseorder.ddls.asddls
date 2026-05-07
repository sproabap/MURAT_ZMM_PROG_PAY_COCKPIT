@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Progress Payment Purchase Order Matching'

@Metadata.ignorePropagatedAnnotations: true

define root view entity ZC_ProgressPayPurchaseOrder
  as select distinct from I_PurchaseOrderItemAPI01    as PurchaseOrderItem

    inner join            I_PurchaseOrderAPI01        as PurchaseOrder        on PurchaseOrder.PurchaseOrder = PurchaseOrderItem.PurchaseOrder
    inner join            ZR_MM_PRG_PAY_LOG           as ProgressPaymentLog   on ProgressPaymentLog.PaymentUuid = PurchaseOrder.YY1_PaymentUUID_PDH
    left outer join       I_PurchaseOrderHistoryAPI01 as PurchaseOrderHistory on PurchaseOrderHistory.PurchaseOrder = PurchaseOrder.PurchaseOrder
    left outer join       I_SupplierInvoiceAPI01      as SupplierInvoiceAPI   on  SupplierInvoiceAPI.FiscalYear      = PurchaseOrderHistory.PurchasingHistoryDocumentYear
                                                                              and SupplierInvoiceAPI.SupplierInvoice = PurchaseOrderHistory.PurchasingHistoryDocument
                                                                              and SupplierInvoiceAPI.ReverseDocument is initial
{
  key PurchaseOrderItem.PurchaseOrder,
  key ProgressPaymentLog.PaymentUuid,
  key ProgressPaymentLog.Transportdocno,
      // PurchaseOrderHistory.PurchasingHistoryDocument ,
      SupplierInvoiceAPI.SupplierInvoice as PurchasingHistoryDocument,
      SupplierInvoiceAPI.SupplierInvoiceIDByInvcgParty
}

where
  PurchaseOrderItem.PurchasingDocumentDeletionCode is initial
//  and(
//       SupplierInvoiceAPI.ReverseDocument               is initial
//    or SupplierInvoiceAPI.ReverseDocument               is null
//  );

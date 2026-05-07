@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Vehicle Categories for Purchasing'

@Metadata.ignorePropagatedAnnotations: true

define root view entity ZI_VehicleCategoryPurhasing
  as select from I_ProductPlantBasic      as ProductPlant

    inner join   I_Plant                  as Plant                  on Plant.Plant = ProductPlant.Plant
    inner join   I_PurchasingOrganization as PurchasingOrganization on PurchasingOrganization.CompanyCode = Plant.ValuationArea

{
  key ProductPlant.Product,
  key PurchasingOrganization.PurchasingOrganization,

      ProductPlant.YY1_PlantVehcCategory_PLT         as VehicleCategory
}

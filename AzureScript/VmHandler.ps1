#-- this script handeler vm on azure --#

#Login to Azure
Login-AzureRmAccount

Stop-AzureVM -ServiceName "VmContactSync" -Name "VmContactSync"
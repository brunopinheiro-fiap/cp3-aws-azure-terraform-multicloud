# Criar Grupo de Recursos
resource "azurerm_resource_group" "rg" {
  name     = "myResourceGroup"
  location = "brazilsouth"
}

# Criar VNet
resource "azurerm_virtual_network" "vnet" {
  name                = "myVNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Criar Subnet Pública
resource "azurerm_subnet" "subnet_public" {
  name                 = "myPublicSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Criar Subnet Privada
resource "azurerm_subnet" "subnet_private" {
  name                 = "myPrivateSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Criar IP Público com SKU Standard e alocação estática
resource "azurerm_public_ip" "public_ip" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"  # Corrigido para Static
  sku                 = "Standard"  # Mantém o SKU Standard
  tags = {
    environment = "Production"
  }
}

# Gateway de Rede para a Subnet Pública (Opcional)
resource "azurerm_network_security_group" "nsg" {
  name                = "myNSG"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Associar NSG à Subnet Pública
resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.subnet_public.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
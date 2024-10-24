# Variáveis para configurar as VNETs e subnets
variable "azure_location" {
  description = "Localização do Azure para os recursos"
  type        = string
  default     = "brazilsouth"
}

variable "vnet10_address_space" {
  description = "Espaço de endereçamento da VNET10 (Pública)"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "vnet20_address_space" {
  description = "Espaço de endereçamento da VNET20 (Privada)"
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "vnet10_subnet_public" {
  description = "Espaço de endereçamento da subnet pública na VNET10"
  type        = string
  default     = "10.0.1.0/24"
}

variable "vnet20_subnet_private" {
  description = "Espaço de endereçamento da subnet privada na VNET20"
  type        = string
  default     = "10.1.1.0/24"
}

# Criar grupo de recursos
resource "azurerm_resource_group" "example" {
  name     = "myResourceGroup"
  location = var.azure_location
}

# VNET10 (Pública)
resource "azurerm_virtual_network" "vnet10" {
  name                = "VNET10"
  address_space       = var.vnet10_address_space
  location            = var.azure_location
  resource_group_name = azurerm_resource_group.example.name
}

# Subnet pública na VNET10
resource "azurerm_subnet" "vnet10_subnet_public" {
  name                 = "PublicSubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.vnet10.name
  address_prefixes     = [var.vnet10_subnet_public]
}

# Interface de rede pública na VNET10
resource "azurerm_network_interface" "public_nic" {
  name                = "PublicNIC"
  location            = var.azure_location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "PublicIPConfig"
    subnet_id                     = azurerm_subnet.vnet10_subnet_public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# IP público para a interface de rede pública
resource "azurerm_public_ip" "public_ip" {
  name                = "PublicIPAddress"
  location            = var.azure_location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
}

# VNET20 (Privada)
resource "azurerm_virtual_network" "vnet20" {
  name                = "VNET20"
  address_space       = var.vnet20_address_space
  location            = var.azure_location
  resource_group_name = azurerm_resource_group.example.name
}

# Subnet privada na VNET20
resource "azurerm_subnet" "vnet20_subnet_private" {
  name                 = "PrivateSubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.vnet20.name
  address_prefixes     = [var.vnet20_subnet_private]
}

# Interface de rede privada na VNET20
resource "azurerm_network_interface" "private_nic" {
  name                = "PrivateNIC"
  location            = var.azure_location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "PrivateIPConfig"
    subnet_id                     = azurerm_subnet.vnet20_subnet_private.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Peering entre VNET10 e VNET20
resource "azurerm_virtual_network_peering" "vnet10_to_vnet20" {
  name                      = "VNET10-to-VNET20"
  resource_group_name       = azurerm_resource_group.example.name
  virtual_network_name      = azurerm_virtual_network.vnet10.name
  remote_virtual_network_id = azurerm_virtual_network.vnet20.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
  use_remote_gateways       = false
}

resource "azurerm_virtual_network_peering" "vnet20_to_vnet10" {
  name                      = "VNET20-to-VNET10"
  resource_group_name       = azurerm_resource_group.example.name
  virtual_network_name      = azurerm_virtual_network.vnet20.name
  remote_virtual_network_id = azurerm_virtual_network.vnet10.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
  use_remote_gateways       = false
}